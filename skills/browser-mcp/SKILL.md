---
name: browser-mcp
description: Use browser automation MCP servers for web app debugging and exploration. Covers when to choose Playwright MCP versus Chrome DevTools MCP, how to configure them, and security/privacy defaults for browser sessions.
---

# Browser MCP (Playwright + Chrome DevTools)

Use this when a task asks for browser automation through MCP, page exploration, UI debugging, console/network inspection, or performance analysis.

## Pick the right server

| Need | Prefer | Why |
| --- | --- | --- |
| Accessibility-tree-driven page interaction, form flows, cross-browser checks, deterministic UI exploration | **Playwright MCP** | Uses Playwright and structured accessibility snapshots; supports Chromium/Firefox/WebKit-style automation. |
| Chrome-specific debugging, console/network inspection, screenshots, Lighthouse, performance traces, heap snapshots | **Chrome DevTools MCP** | Exposes Chrome DevTools capabilities to agents; best for debugging and perf analysis in real Chrome. |
| High-throughput coding agent with lots of repo context and only occasional browser actions | CLI/skill workflow if available | Playwright MCP docs note CLI+skills can be more token-efficient than MCP schemas and accessibility trees. |

Do **not** connect either MCP server to a browser profile containing secrets unless the user explicitly accepts that risk. Both servers expose browser/page contents to the MCP client.

## Hard-won operational rules (read before configuring)

- **Headful needs the display env passed explicitly.** MCP servers inherit the
  agent's shell environment, which on Wayland/Hyprland setups has **no**
  `DISPLAY`/`WAYLAND_DISPLAY` — so a "headed" launch silently runs headless (or
  fails) while tool calls keep succeeding, and the user sees no window. Set the
  env in the server config, e.g.
  `"env": { "XDG_RUNTIME_DIR": "/run/user/1000", "WAYLAND_DISPLAY": "wayland-1", "DISPLAY": ":0" }`.
  Find the live values by reading `/proc/<pid>/environ` of a running desktop
  app or listing `/run/user/<uid>/wayland-*`.
- **Config changes need a session restart.** MCP servers bind once at session
  start; editing the config mid-session leaves the old server (and its
  headless browser) running. Say so and restart rather than fighting it.
- **Attach mode cannot launch.** With `--browserUrl` (Chrome DevTools MCP) the
  server only attaches to an already-running browser on that port; if nothing
  is listening, every tool call fails with "Could not connect to Chrome".
  Spawn mode (`--executablePath`, no `--browserUrl`) launches its own. Pick one
  deliberately; attach is for driving the user's visible window.
- **One tab, navigated in place.** Repeated `new_page` calls pile up duplicate
  tabs; navigate the existing page instead and keep a single working tab.
  Chrome DevTools MCP supports **named isolated contexts**
  (`new_page` `isolatedContext: "<name>"`) — separate cookies/storage per
  name, useful for e.g. signed-in vs anonymous side by side. Tab *groups* are
  an extension API and not reachable over CDP.
- **Machine-specific paths mean local scope.** A Nix `--executablePath` breaks
  for other machines — keep such configs in local/user scope, never committed
  project config.
- **Verify rendering with eyes, not exit codes.** Unit tests and navigations
  passing does not mean the page drew (a canvas can mount empty). Require a
  screenshot or a DOM/pixel check (e.g. count drawn SVG children) before
  claiming a UI works.

## Standard MCP configs

Use the project/client's MCP configuration format. Source docs commonly show `npx`; in Nix/devenv-managed repos, prefer running through the repo dev shell/package manager rather than installing globally.

### Playwright MCP

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Common hardening/session flags:

- `--headless` for headless mode.
- `--isolated` to keep the browser profile in memory and avoid sharing persistent state.
- `--user-data-dir <path>` for an explicit persistent profile; avoid sharing it across concurrent clients.
- `--storage-state <path>` to preload cookies/local storage into an isolated context.
- `--browser <chrome|firefox|webkit|msedge>` to choose the browser/channel.
- `--allowed-origins`, `--blocked-origins`, `--allowed-hosts` to constrain requests/server hosts, while remembering the docs say origin controls are not a full security boundary.
- `--caps <vision,pdf,devtools>` only when those extra capabilities are needed.

### Chrome DevTools MCP

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

For basic browser tasks with fewer tools exposed:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--slim", "--headless"]
    }
  }
}
```

Privacy/offline-ish defaults to consider:

- Add `--usageStatistics=false` or set `CHROME_DEVTOOLS_MCP_NO_USAGE_STATISTICS=1` to opt out of Google usage statistics.
- Add `--performanceCrux=false` when performance tooling should not send trace URLs to the Google CrUX API.
- Set `CHROME_DEVTOOLS_MCP_NO_UPDATE_CHECKS=1` to disable npm update checks.
- Use `--browserUrl=http://127.0.0.1:9222` to attach to an already-running Chrome with remote debugging.
- On Nix/Home Manager systems without Google Chrome, pass an absolute Chromium path, for example `--executablePath /etc/profiles/per-user/$USER/bin/chromium`; a bare `chromium` may initialize but fail when the first page is opened.

## Debugging workflow

1. Start from a clean/isolated profile unless the task requires logged-in state.
2. Navigate to the target URL and capture the current page state.
3. For UI flows, prefer semantic actions from snapshots over pixel coordinates.
4. For failures, collect in this order: console messages, network requests, screenshot/snapshot, then performance trace/heap snapshot only if relevant.
5. Turn findings into code/test changes; rerun the same browser checks to verify.
6. Stop/clear background browser daemons or profiles when done.

## Chrome DevTools CLI escape hatch

`chrome-devtools-mcp` also ships an experimental `chrome-devtools` CLI. It talks to a background daemon, preserves browser state, and can output JSON:

```sh
chrome-devtools status
chrome-devtools new_page "https://example.com"
chrome-devtools take_screenshot --filePath screenshot.png
chrome-devtools list_pages --output-format=json
chrome-devtools stop
```

Use CLI mode when the agent environment has the package installed and a concise command is better than loading MCP tool schemas.

## Sources

- Playwright MCP README: https://github.com/microsoft/playwright-mcp
- Chrome DevTools MCP blog: https://developer.chrome.com/blog/chrome-devtools-mcp
- Chrome DevTools MCP README/tool docs: https://github.com/ChromeDevTools/chrome-devtools-mcp
- More notes: `references/sources.md`
