#!/usr/bin/env node
// Submit a resolved prompt (stdin or --prompt-file), plus optional images, to a
// web image model in a real Chrome window, and print the conversation URL.
//
//   snapshot-prompt.py --resolve IMG-03 | submit-web.mjs --site chatgpt --image photo.jpg
//   submit-web.mjs --site gemini --account you@example.com --prompt-file p.txt --image photo.jpg
//
// Chrome >=136 ignores --remote-debugging-port on the default profile, so this
// drives a dedicated automation profile under $XDG_DATA_HOME/agents/generated-imagery/.
// First run: the window opens signed out — sign in by hand once, re-run. The
// window is left open between runs; later runs attach to it in under a second.
//
// The prompt text is inserted verbatim in one CDP call. Nothing here summarises,
// wraps or edits it.

import { spawn } from "node:child_process";
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
const PORT = Number(process.env.CDP_PORT || 9345);

function die(msg) {
  process.stderr.write(`submit-web: ${msg}\n`);
  process.exit(1);
}

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
  process.stderr.write("submit-web: installing playwright-core (once)…\n");
  execFileSync("npm", ["install", "--prefix", DATA, "playwright-core@^1.50"], {
    stdio: ["ignore", "ignore", "inherit"],
  });
  ({ chromium } = require2("playwright-core"));
}

// ---- attach to (or launch) the automation Chrome ----------------------------
async function cdpAlive() {
  try {
    const res = await fetch(`http://127.0.0.1:${PORT}/json/version`, {
      signal: AbortSignal.timeout(1000),
    });
    return res.ok;
  } catch {
    return false;
  }
}

if (!(await cdpAlive())) {
  const bin =
    process.env.CHROME_BIN ||
    ["google-chrome", "google-chrome-stable", "chromium"].find((b) => {
      try { execFileSync("which", [b], { stdio: "ignore" }); return true; }
      catch { return false; }
    });
  if (!bin) die("no Chrome binary found (set $CHROME_BIN)");
  spawn(
    bin,
    [
      `--user-data-dir=${PROFILE}`,
      `--remote-debugging-port=${PORT}`,
      "--no-first-run",
      "--no-default-browser-check",
    ],
    { detached: true, stdio: "ignore" },
  ).unref();
  const t0 = Date.now();
  while (!(await cdpAlive())) {
    if (Date.now() - t0 > 20000) die("Chrome did not open its debug port");
    await new Promise((r) => setTimeout(r, 300));
  }
}

const browser = await chromium.connectOverCDP(`http://127.0.0.1:${PORT}`);
if (opt.check) {
  process.stdout.write(`ok: attached to ${browser.version()} on port ${PORT}\n`);
  await browser.close();
  process.exit(0);
}
const context = browser.contexts()[0];
const page = await context.newPage();
page.setDefaultTimeout(30000);

const note = (m) => process.stderr.write(`submit-web: ${m}\n`);

// Wait for a streaming indicator to appear (grace period), then disappear.
async function awaitCompletion(stopSel) {
  if (!opt.wait) return;
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
    await composer.waitFor({ timeout: 15000 });
    // ChatGPT shows the composer to anonymous users too, so the composer is no
    // sign-in proof. An anonymous submit lands outside the account's history
    // and is unrecoverable — check the profile button instead.
    try {
      await page
        .locator('[data-testid="accounts-profile-button"]')
        .waitFor({ state: "attached", timeout: 8000 });
    } catch {
      die(
        "signed out — the composer is the anonymous one. " +
        "Sign in to chatgpt.com in the automation Chrome window, then re-run.",
      );
    }
    if (opt.images.length)
      await page
        .locator('form input[type="file"]')
        .first()
        .setInputFiles(opt.images);
    await composer.click();
    await page.keyboard.insertText(prompt);
    // Send stays disabled until every attachment has finished uploading.
    // click() waits for enabled, which is what a slow upload holds back.
    const send = page.locator("#composer-submit-button");
    await send.click({ timeout: 180000 });
    await awaitCompletion('[data-testid="stop-button"]');
  } else {
    await page.goto(
      `https://gemini.google.com/app?authuser=${encodeURIComponent(opt.account)}`,
      { waitUntil: "domcontentloaded" },
    );
    const editor = page.locator("rich-textarea div.ql-editor");
    try {
      await editor.waitFor({ timeout: 15000 });
    } catch {
      die(
        "no composer — the automation profile is signed out of Google. " +
        "Sign in in the Chrome window that just opened, then re-run.",
      );
    }
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
    await editor.click();
    await page.keyboard.insertText(prompt);
    const send = page.locator('button[aria-label="Send message"]');
    await send.click({ timeout: 180000 });
    await awaitCompletion('button[aria-label*="Stop"]');
  }
  // The conversation URL only settles once the exchange exists.
  await page
    .waitForURL(/\/(c|app)\/[A-Za-z0-9_-]+/, { timeout: 30000 })
    .catch(() => {});
  process.stdout.write(page.url() + "\n");
} finally {
  await browser.close(); // disconnects; the Chrome window and the page stay open
}
