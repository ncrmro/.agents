#!/usr/bin/env node
// Submit a resolved prompt (stdin or --prompt-file), plus optional images, to a
// web image model in the user's own Chrome, and print the conversation URL.
//
//   snapshot-prompt.py --resolve IMG-03 | submit-web.mjs --site chatgpt --image photo.jpg
//   submit-web.mjs --site gemini --account you@example.com --prompt-file p.txt --image photo.jpg
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
import { createRequire } from "node:module";
import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const DATA = join(
  process.env.XDG_DATA_HOME || join(process.env.HOME, ".local/share"),
  "agents/generated-imagery",
);

function die(msg) {
  process.stderr.write(`submit-web: ${msg}\n`);
  process.exit(1);
}
const note = (m) => process.stderr.write(`submit-web: ${m}\n`);

// ---- args -------------------------------------------------------------------
const args = process.argv.slice(2);
const opt = { images: [], wait: true, timeout: 900 };
for (let i = 0; i < args.length; i++) {
  const a = args[i];
  if (a === "--site") opt.site = args[++i];
  else if (a === "--image") opt.images.push(args[++i]);
  else if (a === "--prompt-file") opt.promptFile = args[++i];
  else if (a === "--account") opt.account = args[++i];
  else if (a === "--no-wait") opt.wait = false;
  else if (a === "--timeout") opt.timeout = Number(args[++i]);
  else if (a === "--check") opt.check = true;
  else die(`unknown argument ${a}`);
}
if (!opt.check && !["chatgpt", "gemini"].includes(opt.site))
  die("--site chatgpt|gemini is required");
if (!opt.check && opt.site === "gemini" && !opt.account)
  opt.account = process.env.GEMINI_ACCOUNT || die(
    "--site gemini needs --account <email> (or $GEMINI_ACCOUNT). " +
    "Without it the prompt lands silently in whichever Google account is the default.",
  );
for (const img of opt.images)
  if (!existsSync(img)) die(`image not found: ${img}`);

const prompt = opt.check
  ? ""
  : opt.promptFile
    ? readFileSync(opt.promptFile, "utf8")
    : readFileSync(0, "utf8");
if (!opt.check && !prompt.trim()) die("empty prompt (stdin or --prompt-file)");

// ---- playwright-core, vendored outside the repo -----------------------------
mkdirSync(DATA, { recursive: true });
const require2 = createRequire(pathToFileURL(join(DATA, "_resolve.js")));
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

// ---- attach to the running Chrome -------------------------------------------
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
const browser = await chromium.connectOverCDP(endpoint);
if (opt.check) {
  process.stdout.write(`ok: attached to ${browser.version()} at ${endpoint}\n`);
  await browser.close();
  process.exit(0);
}
const page = await browser.contexts()[0].newPage();
page.setDefaultTimeout(30000);

// Wait for a streaming indicator to appear (grace period), then disappear.
async function awaitCompletion(stopSel) {
  if (!opt.wait) {
    // The submit is client-side until the request is fully away; give it a
    // beat before disconnecting.
    await page.waitForTimeout(5000);
    return;
  }
  note("waiting for the response to finish…");
  try {
    await page.waitForSelector(stopSel, { state: "visible", timeout: 20000 });
  } catch {} // fast responses can finish inside the grace period
  await page.waitForSelector(stopSel, {
    state: "hidden",
    timeout: opt.timeout * 1000,
  });
}

try {
  if (opt.site === "chatgpt") {
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
    await composer.click();
    await page.keyboard.insertText(prompt);
    // click() waits for enabled, which is what a slow upload holds back.
    await page.locator("#composer-submit-button").click({ timeout: 180000 });
    await awaitCompletion('[data-testid="stop-button"]');
  } else {
    await page.goto(
      `https://gemini.google.com/app?authuser=${encodeURIComponent(opt.account)}`,
      { waitUntil: "domcontentloaded" },
    );
    await page
      .locator("rich-textarea div.ql-editor")
      .waitFor({ timeout: 20000 })
      .catch(() => die(`this Chrome is signed out of Google (${opt.account})`));
    // Assert the account, loudly: the failure mode of authuser is the prompt
    // landing in the default account's history without a word said.
    const chip = await page
      .locator('a[aria-label*="Google Account"]')
      .first()
      .getAttribute("aria-label");
    if (!chip || !chip.includes(opt.account))
      die(`wrong account: wanted ${opt.account}, page shows "${chip}"`);
    if (opt.images.length) {
      // The file inputs exist only while the upload menu is open.
      await page.locator('button[aria-label="Upload & tools"]').click();
      const input = page.locator('input[type="file"][accept="image/*"]');
      await input.waitFor({ state: "attached", timeout: 10000 });
      await input.setInputFiles(opt.images);
      await page.keyboard.press("Escape");
    }
    await page.locator("rich-textarea div.ql-editor").click();
    await page.keyboard.insertText(prompt);
    await page
      .locator('button[aria-label="Send message"]')
      .click({ timeout: 180000 });
    await awaitCompletion('button[aria-label*="Stop"]');
  }
  // The conversation URL only settles once the exchange exists.
  await page
    .waitForURL(/\/(c|app)\/[A-Za-z0-9_-]+/, { timeout: 30000 })
    .catch(() => {});
  process.stdout.write(page.url() + "\n");
} finally {
  // Disconnect only: the tab stays open for the share-link step.
  await browser.close();
}
