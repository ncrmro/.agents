#!/usr/bin/env node
// Submit a resolved prompt (stdin or --prompt-file), plus optional images, to a
// web image model in the user's own Chrome, print the conversation URL, and
// append a provenance line under $IMAGESET_ROOT/out/.
//
//   snapshot-prompt.py --resolve IMG-03 | submit-web.mjs --site chatgpt --image photo.jpg
//   submit-web.mjs --site gemini --account you@example.com --prompt-file p.txt --image photo.jpg
//   submit-web.mjs --check
//
// The script attaches over CDP to the running, signed-in Chrome session. The
// user enables that once via the consent toggle at
// chrome://inspect/#remote-debugging, which opens the endpoint on the current
// session (the --remote-debugging-port flag is refused on the default profile
// in modern Chrome). Each run opens a fresh tab, submits there, and leaves the
// tab open on disconnect.
//
// The prompt text is inserted verbatim in one CDP call. Nothing here summarises,
// wraps or edits it.

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { createRequire } from "node:module";
import { appendFileSync, existsSync, mkdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const DATA = join(
  process.env.XDG_DATA_HOME || join(process.env.HOME, ".local/share"),
  "agents/generated-imagery",
);
const ROOT = process.env.IMAGESET_ROOT || process.cwd();
const UPLOAD_GRACE_MS = 180_000; // a slow image upload holds the send button disabled
const RESPONSE_TIMEOUT_MS = 900_000;

const USAGE = `usage: submit-web.mjs --site chatgpt|gemini [options] < resolved-prompt.txt
  --site chatgpt|gemini   where to submit (required)
  --account <email>       Gemini only, required there ($GEMINI_ACCOUNT): the
                          non-default Google account the prompt must land in
  --image <path>          attach an image; repeatable
  --prompt-file <path>    read the prompt from a file instead of stdin
  --check                 verify the Chrome attach and exit; submits nothing
Enable the endpoint once: chrome://inspect/#remote-debugging in the Chrome you
are signed into ($CDP_PORT overrides port 9222).`;

function die(msg) {
  process.stderr.write(`submit-web: ${msg}\n`);
  process.exit(1);
}
const note = (m) => process.stderr.write(`submit-web: ${m}\n`);

// ---- args -------------------------------------------------------------------
const args = process.argv.slice(2);
const opt = { images: [], check: false };
for (let i = 0; i < args.length; i++) {
  const a = args[i];
  const need = () => {
    const v = args[++i];
    if (v === undefined || v.startsWith("--")) die(`${a} needs a value`);
    return v;
  };
  if (a === "--site") opt.site = need();
  else if (a === "--image") opt.images.push(need());
  else if (a === "--prompt-file") opt.promptFile = need();
  else if (a === "--account") opt.account = need();
  else if (a === "--check") opt.check = true;
  else if (a === "-h" || a === "--help") { console.log(USAGE); process.exit(0); }
  else die(`unknown argument ${a}\n${USAGE}`);
}

let prompt = "";
if (!opt.check) {
  if (!["chatgpt", "gemini"].includes(opt.site))
    die(`--site chatgpt|gemini is required\n${USAGE}`);
  if (opt.site === "gemini" && !opt.account)
    opt.account = process.env.GEMINI_ACCOUNT || die(
      "--site gemini needs --account <email> (or $GEMINI_ACCOUNT). " +
      "Without it the prompt lands silently in whichever Google account is the default.",
    );
  if (opt.site === "chatgpt" && opt.account)
    die(
      "--account applies to --site gemini only; ChatGPT uses whichever " +
      "account this Chrome is signed into",
    );
  for (const img of opt.images)
    if (!existsSync(img)) die(`image not found: ${img}`);
  prompt = readFileSync(opt.promptFile ?? 0, "utf8");
  if (!prompt.trim()) die("empty prompt (stdin or --prompt-file)");
}

// ---- probe the endpoint before anything slow --------------------------------
const port = Number(process.env.CDP_PORT || 9222);
const endpoint = `http://127.0.0.1:${port}`;
try {
  const res = await fetch(`${endpoint}/json/version`, {
    signal: AbortSignal.timeout(1500),
  });
  if (!res.ok) throw new Error();
} catch {
  die(
    `no Chrome debug endpoint on :${port}. Enable it once in the Chrome you ` +
    "are signed into: open chrome://inspect/#remote-debugging and allow it, " +
    "then re-run. ($CDP_PORT overrides the port.)",
  );
}

// ---- playwright-core, vendored outside the repo -----------------------------
mkdirSync(DATA, { recursive: true });
const require2 = createRequire(join(DATA, "_resolve.js"));
let chromium;
try {
  ({ chromium } = require2("playwright-core"));
} catch {
  note("installing playwright-core (once)…");
  execFileSync("npm", ["install", "--prefix", DATA, "playwright-core@^1.50"], {
    stdio: ["ignore", "ignore", "inherit"],
  });
  ({ chromium } = require2("playwright-core"));
}

// ---- attach -----------------------------------------------------------------
const browser = await chromium.connectOverCDP(endpoint);
if (opt.check) {
  process.stdout.write(`ok: attached to ${browser.version()} at ${endpoint}\n`);
  await browser.close();
  process.exit(0);
}
const page = await browser.contexts()[0].newPage();
page.setDefaultTimeout(30000);

// Wait for the streaming indicator to appear, then disappear. The stop
// selectors are inferred, not read from the live DOM, and a selector that
// matches nothing satisfies a hidden-wait immediately — so an indicator that
// never appears is announced rather than treated as completion.
async function awaitCompletion(stopSel) {
  note("waiting for the response to finish…");
  const appeared = await page
    .waitForSelector(stopSel, { state: "visible", timeout: 20000 })
    .then(() => true, () => false);
  if (!appeared) {
    note(`stop indicator ${stopSel} never appeared — completion not observed`);
    return;
  }
  try {
    await page.waitForSelector(stopSel, {
      state: "hidden",
      timeout: RESPONSE_TIMEOUT_MS,
    });
  } catch {
    // The submit itself succeeded; keep the URL, fail the exit status.
    note("response still streaming after the timeout — printing the URL anyway");
    process.exitCode = 1;
  }
}

// The submit policy both sites share: insert the prompt verbatim in one CDP
// call, let click() wait out a slow upload (it waits for enabled), then watch
// the stream.
async function submit(composer, send, stopSel) {
  await composer.click();
  await page.keyboard.insertText(prompt);
  await send.click({ timeout: UPLOAD_GRACE_MS });
  await awaitCompletion(stopSel);
}

let urlPattern;
try {
  if (opt.site === "chatgpt") {
    urlPattern = /\/c\/[A-Za-z0-9_-]+/;
    await page.goto("https://chatgpt.com/", { waitUntil: "domcontentloaded" });
    const composer = page.locator("#prompt-textarea");
    await composer.waitFor({ timeout: 20000 });
    // ChatGPT shows the composer to anonymous users too, so the composer is no
    // sign-in proof. An anonymous submit lands outside the account's history
    // and is unrecoverable — check the profile button instead.
    await page
      .locator('[data-testid="accounts-profile-button"]')
      .waitFor({ state: "attached", timeout: 8000 })
      .catch(() => die("this Chrome is signed out of chatgpt.com"));
    if (opt.images.length)
      await page
        .locator('form input[type="file"]')
        .first()
        .setInputFiles(opt.images);
    await submit(
      composer,
      page.locator("#composer-submit-button"),
      '[data-testid="stop-button"]',
    );
  } else {
    urlPattern = /\/app\/[A-Za-z0-9]+/;
    await page.goto(
      `https://gemini.google.com/app?authuser=${encodeURIComponent(opt.account)}`,
      { waitUntil: "domcontentloaded" },
    );
    const editor = page.locator("rich-textarea div.ql-editor");
    await editor
      .waitFor({ timeout: 20000 })
      .catch(() => die(`this Chrome is signed out of Google (${opt.account})`));
    // Assert the account, loudly: the failure mode of authuser is the prompt
    // landing in the default account's history without a word said.
    const chip = page.locator('a[aria-label*="Google Account"]').first();
    await chip
      .waitFor({ state: "attached", timeout: 10000 })
      .catch(() =>
        die(
          "could not read the Google account chip; cannot confirm the " +
          `prompt would land in ${opt.account}`,
        ),
      );
    const label = await chip.getAttribute("aria-label");
    if (!label || !label.includes(opt.account))
      die(`wrong account: wanted ${opt.account}, page shows "${label}"`);
    if (opt.images.length) {
      // The file inputs exist only while the upload menu is open.
      await page.locator('button[aria-label="Upload & tools"]').click();
      const input = page.locator('input[type="file"][accept="image/*"]');
      await input.waitFor({ state: "attached", timeout: 10000 });
      await input.setInputFiles(opt.images);
      await page.keyboard.press("Escape");
    }
    await submit(
      editor,
      page.locator('button[aria-label="Send message"]'),
      'button[aria-label*="Stop"]',
    );
  }

  // The conversation URL only settles once the exchange exists. A homepage URL
  // is not the deliverable, so a URL that never settles is a failure, not output.
  const settled = await page
    .waitForURL(urlPattern, { timeout: 30000 })
    .then(() => true, () => false);
  const url = settled ? page.url() : null;

  // The provenance row ties the conversation to the exact text submitted, in
  // the same file generate.sh appends to.
  mkdirSync(join(ROOT, "out"), { recursive: true });
  appendFileSync(
    join(ROOT, "out", "provenance.jsonl"),
    JSON.stringify({
      prompt: createHash("sha256").update(prompt).digest("hex"),
      at: new Date().toISOString(),
      model: `web:${opt.site}`,
      account: opt.account ?? null,
      images: opt.images,
      url,
    }) + "\n",
  );

  if (!settled) {
    note(`the page never reached a conversation URL (still at ${page.url()})`);
    process.exitCode = 1;
  } else {
    process.stdout.write(url + "\n");
  }
} finally {
  // Disconnect only: the tab stays open for the share-link step.
  await browser.close();
}
