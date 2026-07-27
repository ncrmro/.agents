# Browser MCP source notes

Fetched 2026-07-25.

## Playwright MCP

Source: https://github.com/microsoft/playwright-mcp (`README.md`)

Source claims summarized:

- Playwright MCP is an MCP server that provides browser automation with Playwright.
- It enables LLMs to interact with pages through structured accessibility snapshots instead of screenshots/vision models.
- Requirements include Node.js 18+ and an MCP client.
- Standard config:

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

- The README contrasts CLI+skills and MCP: CLI+skills can be more token-efficient for coding agents; MCP remains useful for specialized loops needing persistent state, rich introspection, and iterative reasoning over page structure.
- Important options include `--headless`, `--isolated`, `--user-data-dir`, `--storage-state`, `--browser`, `--caps`, `--allowed-hosts`, `--allowed-origins`, `--blocked-origins`, `--cdp-endpoint`, `--device`, `--mobile`, `--viewport-size`, and timeout/output controls.
- Security section: browser automation can access page/session data; isolate profiles and constrain origins/hosts when appropriate.

## Chrome DevTools MCP / Chrome DevTools for agents

Sources:

- Blog: https://developer.chrome.com/blog/chrome-devtools-mcp
- Repo: https://github.com/ChromeDevTools/chrome-devtools-mcp (`README.md`, `docs/cli.md`, `docs/tool-reference.md`)

Source claims summarized:

- Chrome DevTools MCP is now part of "Chrome DevTools for agents" and exposes Chrome DevTools capabilities to AI coding assistants.
- It can control and inspect a live Chrome browser via MCP.
- Key features include performance traces/insights, network request analysis, screenshots, console messages with source-mapped stack traces, and reliable automation through Puppeteer.
- Standard config:

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

- Slim config for basic browser tasks:

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

- Disclaimers: the MCP server exposes browser contents to clients; avoid sensitive/personal data in connected browser instances.
- Official browser support is Google Chrome and Chrome for Testing.
- Performance tools may send trace URLs to Google CrUX API unless `--performanceCrux=false` is used.
- Usage statistics are enabled by default and can be disabled with `--usageStatistics=false` or `CHROME_DEVTOOLS_MCP_NO_USAGE_STATISTICS`; `CI` also disables collection.
- Update checks can be disabled with `CHROME_DEVTOOLS_MCP_NO_UPDATE_CHECKS`.
- Tool groups in the tool reference include input automation, navigation automation, emulation, performance, network, debugging, memory, extensions, third-party, and WebMCP.
- The experimental `chrome-devtools` CLI can start/reuse a background daemon, run tools, output JSON, and be stopped with `chrome-devtools stop`.
