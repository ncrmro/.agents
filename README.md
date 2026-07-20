# .agents

Personal, project-agnostic composition layer for shared agent dotfiles.

```
~/.agents/<skills/,subagents/,mcp.json>
~/repos/acme/road-runner
```

## Local Development

Creating shareable agent dotfiles involves careful consideration to keep velocity from getting slowed by this (agentic) platform work.

## How precedence works

Outfitter merges `profile_sources` **last-wins**: the *last* entry in the YAML list is the *highest* precedence for same-ID profiles and skills. This repository is always listed last, so:

- Personal roles and skills here override same-ID resources from every upstream catalog.
- New or experimental resources start here, get validated in real consumers, then trickle upstream — generalize them, move them to the owning repository, and behavior stays identical because this layer keeps overriding until the upstream version lands.

## What's here

| Path | Purpose |
| --- | --- |
| `skills/` | Protocol-native personal skills shared across projects |
| `legacy/outfitter/profiles/` | Transitional Outfitter 0.10 roles (`founder`, `engineer`, `platform`, `researcher`) |
| `legacy/outfitter/settings.yml` | Portable source graph pinned to published GitHub revisions |
| `legacy/outfitter/local/settings.yml` | Ignored machine-local graph pointing at live checkouts (see runbook) |
| `AGENTS.md` | Agent orientation: precedence, source graph, layout |
| `CONTRIBUTING.md` | Scope rules and change standards for committed changes |
| `docs/runbook/agent.dotfile-development.md` | Adoption flow: personal `~/.agents` layer first, then local checkouts, then projects |
| `docs/runbook/local-development.md` | Machine setup, live source graph, validation, publish workflow |

## Quick start

**Adopting agent dotfiles from scratch** — follow the [adoption runbook](docs/runbook/agent.dotfile-development.md): personal layer first, then local checkouts, then projects.

**Consume the published graph** — commit a compatibility `.outfitter/settings.yml` in your project with pinned sources, keeping `ncrmro/.agents/legacy/outfitter/profiles` ahead of the project-local profile source.

**Develop live** — follow the [agent dotfile runbook](docs/runbook/agent.dotfile-development.md) to point an ignored `.outfitter/local/settings.yml` at local checkouts, then validate with:

```bash
outfitter profile lint --strict
outfitter profile list
```

## Upstream sources

- [ai-outfitter/default-profiles](https://github.com/ai-outfitter/default-profiles) — default roles
- [ai-outfitter/community-profiles](https://github.com/ai-outfitter/community-profiles) — community roles
- [ai-outfitter/outfitter](https://github.com/ai-outfitter/outfitter) — the Outfitter CLI and its skill
- [ai-outfitter/actions](https://github.com/ai-outfitter/actions) — `outfitter-actions` skill
