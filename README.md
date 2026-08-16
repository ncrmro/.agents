# .agents

Personal, project-agnostic composition layer for shared agent dotfiles.

```
~/.agents/<skills/,subagents/,mcp.json>
~/repos/acme/road-runner
```

## Local Development

Creating shareable agent dotfiles involves careful consideration to keep velocity from getting slowed by this (agentic) platform work.

## How precedence works

Outfitter v1 resolves resources from project `.agents/`, then global `~/.agents/`, then configured `sources` in listed order. This repository is the global layer, so:

- Personal agents and skills here override same-ID resources from every upstream catalog.
- New or experimental resources start here, get validated in real consumers, then trickle upstream — see [moving resources between layers](docs/runbook/agent.dotfile-development.md#moving-resources-between-layers).

## What's here

| Path                                        | Purpose                                                                              |
| ------------------------------------------- | ------------------------------------------------------------------------------------ |
| `agents/`                                   | Personal native Outfitter v1 agent definitions                                      |
| `skills/`                                   | Native v1 skills shared by those agents and consuming projects                       |
| `settings.yml`                              | v1 defaults and published sources                                                    |
| `settings.local.yml`                        | Ignored machine-local source overrides (see runbook)                                 |
| `mcp.json`                                  | Shared MCP servers selected by agent loadouts                                        |
| `profiles/`                                 | Frozen pre-v1 snapshot (see `AGENTS.md`)                                             |
| `AGENTS.md`                                 | Agent orientation: precedence, source graph, layout                                  |
| `CONTRIBUTING.md`                           | Scope rules and change standards for committed changes                               |
| `docs/runbook/agent.dotfile-development.md` | Adoption flow: personal `~/.agents` layer first, then local checkouts, then projects |

## Quick start

**Adopting agent dotfiles from scratch** — follow the [adoption runbook](docs/runbook/agent.dotfile-development.md): personal layer first, then local checkouts, then projects.

**Use this repository globally** — link or clone it at `~/.agents`. Outfitter v1 resolves these agents automatically as the global layer; projects can add higher-precedence resources in `<project>/.agents/`.

**Develop live** — put machine-specific source paths in ignored `settings.local.yml`, then run `outfitter validate`; the full validation and inspection commands are in the [runbook](docs/runbook/agent.dotfile-development.md#step-2-point-at-local-development-checkouts).

**Enable Playwright MCP** — run `scripts/install-playwright-mcp.sh` once per machine. It installs `playwright-mcp` and Nix-managed Chromium browsers into the default Nix profile, writes a PATH wrapper at `~/.local/bin/mcp-server-playwright`, and verifies that the `mcp.json` command can start.

**Enable Chrome DevTools MCP** — link `scripts/chrome-devtools-mcp-xdg` into a
directory on `PATH` as `chrome-devtools-mcp-xdg`. The launcher reads the XDG
default browser desktop entry at startup and passes its Chromium-family
executable to Chrome DevTools MCP. It does not use the browser's persistent
profile.

## Upstream sources

- [ai-outfitter/default-profiles](https://github.com/ai-outfitter/default-profiles) — published v1 defaults

The pinned default catalog supplies `founder` and pins its reviewed community catalog.

The frozen legacy profile graph in `settings.yml` also pins community-profiles, Outfitter, and Actions for pre-v1 clients.
