#!/usr/bin/env node
// Submit a resolved prompt (stdin or --prompt-file), plus optional images, to a
// web image model in a real Chrome window, and print the conversation URL.
//
//   snapshot-prompt.py --resolve IMG-03 | submit-web.mjs --site chatgpt --image photo.jpg
//   submit-web.mjs --site gemini --account you@example.com --prompt-file p.txt --image photo.jpg
//
// Chrome runs headed on a dedicated automation profile under
// $XDG_DATA_HOME/agents/generated-imagery/ — no remote debugging port, so
// nothing local can drive the signed-in browser between runs. Playwright owns
// the process: launched per run, closed when the run ends. On a signed-out
// profile the script holds the window open and waits for you to sign in by
// hand, then continues.
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
const PROFILE = join(DATA, "chrome-profile");

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

// ---- launch the automation profile ------------------------------------------
const bin =
  process.env.CHROME_BIN ||
  ["google-chrome", "google-chrome-stable", "chromium"].find((b) => {
    try { execFileSync("which", [b], { stdio: "ignore" }); return true; }
    catch { return false; }
  });
if (!bin) die("no Chrome binary found (set $CHROME_BIN)");

const context = await chromium.launchPersistentContext(PROFILE, {
  executablePath: execFileSync("which", [bin]).toString().trim(),
  headless: false,
  viewport: null,
});
if (opt.check) {
  process.stdout.write(`ok: launched ${bin} on profile ${PROFILE}\n`);
  await context.close();
  process.exit(0);
}
const page = context.pages()[0] ?? (await context.newPage());
page.setDefaultTimeout(30000);

// A signed-out profile is a one-time state: hold the window open and let the
// signed-in marker appear whenever the sign-in (done by hand) completes.
async function signedInOrWait(marker, what) {
  const found = await marker
    .waitFor({ state: "attached", timeout: 8000 })
    .then(() => true, () => false);
  if (found) return;
  note(`signed out — sign in to ${what} in this window; waiting up to 10 min…`);
  await marker
    .waitFor({ state: "attached", timeout: 600000 })
    .catch(() => die(`still signed out of ${what} after 10 min`));
  note("signed in, continuing");
}

// Wait for a streaming indicator to appear (grace period), then disappear.
async function awaitCompletion(stopSel) {
  if (!opt.wait) {
    // The submit is client-side until the request is fully away; give it a beat
    // before the context (and browser) closes.
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
    await signedInOrWait(
      page.locator('[data-testid="accounts-profile-button"]'),
      "chatgpt.com",
    );
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
    await signedInOrWait(
      page.locator("rich-textarea div.ql-editor"),
      `Google (${opt.account})`,
    );
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
  await context.close();
}
