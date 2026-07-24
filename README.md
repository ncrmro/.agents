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
| `agents/`                                   | Native Outfitter v1 agents (`founder`, `engineer`, `platform`, `researcher`)         |
| `skills/`                                   | Native v1 skills shared by those agents and consuming projects                       |
| `settings.yml`                              | v1 defaults and published sources                                                    |
| `settings.local.yml`                        | Ignored machine-local source overrides (see runbook)                                 |
| `profiles/`                                 | Frozen pre-v1 snapshot (see `AGENTS.md`)                                             |
| `AGENTS.md`                                 | Agent orientation: precedence, source graph, layout                                  |
| `CONTRIBUTING.md`                           | Scope rules and change standards for committed changes                               |
| `docs/runbook/agent.dotfile-development.md` | Adoption flow: personal `~/.agents` layer first, then local checkouts, then projects |

## Quick start

**Adopting agent dotfiles from scratch** — follow the [adoption runbook](docs/runbook/agent.dotfile-development.md): personal layer first, then local checkouts, then projects.

**Use this repository globally** — link or clone it at `~/.agents`. Outfitter v1 resolves these agents automatically as the global layer; projects can add higher-precedence resources in `<project>/.agents/`.

**Develop live** — put machine-specific source paths in ignored `settings.local.yml`, then run `outfitter validate`; the full validation and inspection commands are in the [runbook](docs/runbook/agent.dotfile-development.md#step-2-point-at-local-development-checkouts).

## Upstream sources

- [ai-outfitter/default-profiles](https://github.com/ai-outfitter/default-profiles) — published v1 defaults

The frozen legacy profile graph in `settings.yml` also pins community-profiles, Outfitter, and Actions for pre-v1 clients.
