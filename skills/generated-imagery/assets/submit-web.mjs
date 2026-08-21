#!/usr/bin/env node
// Submit a resolved prompt (stdin or --prompt-file), plus optional images, to a
// web image model in the user's own Chrome, print the conversation URL, and
// append a provenance line under $IMAGESET_ROOT/out/.
//
//   snapshot-prompt.py --resolve IMG-03 | submit-web.mjs --site chatgpt --image photo.jpg
//   submit-web.mjs --site gemini --account you@example.com --prompt-file p.txt --image photo.jpg
//   submit-web.mjs --check
//
// The user enables Chrome's consent toggle once (chrome://inspect/#remote-debugging);
// Chrome then publishes a secret websocket in the profile's DevToolsActivePort
// file, and asks for permission per connection — in whichever window it
// pleases. So the CLI never connects directly: it auto-starts a daemon that
// connects once (one Allow click, ever) and holds that approved connection,
// and every submit is a job sent to the daemon over a unix socket. The daemon
// dies with the browser; kill it early with: pkill -f "submit-web.mjs --serve"
//
// The prompt text is inserted verbatim in one CDP call. Nothing here summarises,
// wraps or edits it.

import { execFileSync, spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { createRequire } from "node:module";
import {
  appendFileSync,
  existsSync,
  mkdirSync,
  readFileSync,
  unlinkSync,
} from "node:fs";
import net from "node:net";
import { join, resolve } from "node:path";

const DATA = join(
  process.env.XDG_DATA_HOME || join(process.env.HOME, ".local/share"),
  "agents/generated-imagery",
);
const SOCK = join(DATA, "cdp-daemon.sock");
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
First run: enable chrome://inspect/#remote-debugging once, then click Allow on
the one permission prompt — the daemon keeps that connection, no prompts after.`;

function die(msg) {
  process.stderr.write(`submit-web: ${msg}\n`);
  process.exit(1);
}
const note = (m) => process.stderr.write(`submit-web: ${m}\n`);

// ---- args -------------------------------------------------------------------
const args = process.argv.slice(2);
const opt = { images: [], check: false, serve: false };
for (let i = 0; i < args.length; i++) {
  const a = args[i];
  const need = () => {
    const v = args[++i];
    if (v === undefined || v.startsWith("--")) die(`${a} needs a value`);
    return v;
  };
  if (a === "--site") opt.site = need();
  else if (a === "--image") opt.images.push(resolve(need()));
  else if (a === "--prompt-file") opt.promptFile = need();
  else if (a === "--account") opt.account = need();
  else if (a === "--check") opt.check = true;
  else if (a === "--serve") opt.serve = true; // internal: the daemon
  else if (a === "-h" || a === "--help") { console.log(USAGE); process.exit(0); }
  else die(`unknown argument ${a}\n${USAGE}`);
}

// =============================================================================
// Daemon: connect to Chrome once, hold the approved connection, run jobs.
// =============================================================================
if (opt.serve) {
  await serve();
  process.exit(0);
}

async function serve() {
  // playwright-core, vendored outside the repo
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

  // The consent toggle publishes its port and a secret browser-socket path in
  // the profile's DevToolsActivePort file; the port answers no HTTP discovery.
  function activeEndpoint() {
    if (process.env.CDP_PORT)
      return { port: Number(process.env.CDP_PORT), path: "" };
    for (const dir of [
      process.env.CHROME_USER_DATA_DIR,
      join(process.env.HOME, ".config/google-chrome"),
      join(process.env.HOME, ".config/chromium"),
    ].filter(Boolean)) {
      try {
        const [port, path] = readFileSync(join(dir, "DevToolsActivePort"), "utf8")
          .trim()
          .split("\n");
        return { port: Number(port), path };
      } catch {}
    }
    return { port: 9222, path: "" };
  }

  const { port, path: wsPath } = activeEndpoint();
  const listening = await fetch(`http://127.0.0.1:${port}/`, {
    signal: AbortSignal.timeout(1500),
  }).then(() => true, () => false);
  if (!listening)
    die(
      `no Chrome debug endpoint on :${port}. Enable it once in the Chrome you ` +
      "are signed into: open chrome://inspect/#remote-debugging and allow it, " +
      "then re-run. ($CDP_PORT overrides the port.)",
    );
  const endpoint = wsPath
    ? `ws://127.0.0.1:${port}${wsPath}`
    : `http://127.0.0.1:${port}`;

  const cleanup = () => { try { unlinkSync(SOCK); } catch {} };
  process.on("SIGTERM", () => { cleanup(); process.exit(0); });
  cleanup(); // a stale socket from a dead daemon

  // Listen before connecting, and let jobs queue on this promise: a CLI that
  // arrives while the user is still hunting the Allow prompt must find the
  // socket, not conclude there is no daemon and spawn a second one — a second
  // connection is a second prompt, which is the disease this daemon treats.
  let browserReady;
  const browserP = new Promise((r) => (browserReady = r));

  const server = net.createServer((conn) => {
    let buf = "";
    conn.on("data", async (chunk) => {
      buf += chunk;
      const nl = buf.indexOf("\n");
      if (nl === -1) return;
      const job = JSON.parse(buf.slice(0, nl));
      buf = "";
      const emit = (o) => conn.write(JSON.stringify(o) + "\n");
      try {
        const done = await runJob(await browserP, job, (m) => emit({ note: m }));
        emit({ done });
      } catch (e) {
        emit({ done: { error: e.message ?? String(e), code: 1 } });
      }
      conn.end();
    });
  });
  server.listen(SOCK);

  note(
    "connecting to Chrome — click Allow on the permission prompt (it may be " +
    "on another window or workspace — dismiss any stale stacked prompts and " +
    "Allow the newest). This is the only time.",
  );
  // An Allow does not unblock a connection that is already pending — it
  // approves the next one. So attempt in short cycles: the attempt right
  // after the user's click goes straight through.
  let browser = null;
  const t0 = Date.now();
  while (!browser) {
    browser = await chromium
      .connectOverCDP(endpoint, { timeout: 15000 })
      .catch(() => null);
    if (!browser && Date.now() - t0 > 1_800_000) {
      cleanup();
      die("could not attach to Chrome within 30 min of retries");
    }
    if (!browser) note("retrying — click Allow on the newest prompt…");
  }
  note(`attached to ${browser.version()}; holding the connection`);
  browser.on("disconnected", () => { cleanup(); process.exit(0); });
  browserReady(browser);
  await new Promise(() => {}); // run until the browser goes away
}

// A job failure is an answer for one client, not a reason to drop the browser.
class JobError extends Error {}

async function runJob(browser, job, note) {
  if (job.check) return { version: browser.version(), code: 0 };
  const { opt, prompt } = job;
  const page = await browser.contexts()[0].newPage();
  page.setDefaultTimeout(30000);
  let code = 0;

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
      code = 1;
    }
  }

  // The submit policy both sites share: insert the prompt verbatim in one CDP
  // call, let click() wait out a slow upload (it waits for enabled), then
  // watch the stream.
  async function submit(composer, send, stopSel) {
    await composer.click();
    await page.keyboard.insertText(prompt);
    await send.click({ timeout: UPLOAD_GRACE_MS });
    await awaitCompletion(stopSel);
  }

  let urlPattern;
  if (opt.site === "chatgpt") {
    urlPattern = /\/c\/[A-Za-z0-9_-]+/;
    await page.goto("https://chatgpt.com/", { waitUntil: "domcontentloaded" });
    const composer = page.locator("#prompt-textarea");
    await composer.waitFor({ timeout: 20000 });
    // ChatGPT shows the composer to anonymous users too, so the composer is no
    // sign-in proof. An anonymous submit lands outside the account's history
    // and is unrecoverable — check the profile button instead.
    const signedIn = await page
      .locator('[data-testid="accounts-profile-button"]')
      .waitFor({ state: "attached", timeout: 8000 })
      .then(() => true, () => false);
    if (!signedIn) throw new JobError("this Chrome is signed out of chatgpt.com");
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
    const signedIn = await editor
      .waitFor({ timeout: 20000 })
      .then(() => true, () => false);
    if (!signedIn)
      throw new JobError(`this Chrome is signed out of Google (${opt.account})`);
    // Assert the account, loudly: the failure mode of authuser is the prompt
    // landing in the default account's history without a word said.
    const chip = page.locator('a[aria-label*="Google Account"]').first();
    const chipThere = await chip
      .waitFor({ state: "attached", timeout: 10000 })
      .then(() => true, () => false);
    if (!chipThere)
      throw new JobError(
        "could not read the Google account chip; cannot confirm the prompt " +
        `would land in ${opt.account}`,
      );
    const label = await chip.getAttribute("aria-label");
    if (!label || !label.includes(opt.account))
      throw new JobError(
        `wrong account: wanted ${opt.account}, page shows "${label}"`,
      );
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
  if (!settled) {
    note(`the page never reached a conversation URL (still at ${page.url()})`);
    code = 1;
  }
  // The tab stays open for the share-link step.
  return { url: settled ? page.url() : null, code };
}

// =============================================================================
// CLI: validate, read the prompt, hand the job to the daemon, relay its notes.
// =============================================================================
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

function connectSock() {
  return new Promise((resolve_, reject) => {
    const c = net.createConnection(SOCK);
    c.once("connect", () => resolve_(c));
    c.once("error", reject);
  });
}

let conn;
try {
  conn = await connectSock();
} catch {
  note("starting the browser daemon…");
  mkdirSync(DATA, { recursive: true });
  spawn(process.execPath, [process.argv[1], "--serve"], {
    detached: true,
    stdio: ["ignore", "ignore", "inherit"], // its notes (Allow prompt!) reach this terminal
  }).unref();
  const t0 = Date.now();
  for (;;) {
    await new Promise((r) => setTimeout(r, 500));
    try { conn = await connectSock(); break; } catch {}
    if (Date.now() - t0 > 200_000)
      die("the daemon never came up — see its messages above");
  }
}

conn.write(
  JSON.stringify(
    opt.check
      ? { check: true }
      : { opt: { site: opt.site, account: opt.account ?? null, images: opt.images }, prompt },
  ) + "\n",
);

let buf = "";
conn.on("data", (chunk) => {
  buf += chunk;
  let nl;
  while ((nl = buf.indexOf("\n")) !== -1) {
    const msg = JSON.parse(buf.slice(0, nl));
    buf = buf.slice(nl + 1);
    if (msg.note) note(msg.note);
    if (msg.done) finish(msg.done);
  }
});
conn.on("close", () => die("the daemon closed the connection without a result"));

function finish(done) {
  if (done.error) die(done.error);
  if (opt.check) {
    process.stdout.write(`ok: daemon attached to ${done.version}\n`);
    process.exit(0);
  }
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
      url: done.url,
    }) + "\n",
  );
  if (done.url) process.stdout.write(done.url + "\n");
  process.exit(done.code);
}
