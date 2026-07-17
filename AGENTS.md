# Shared agent configuration

This repository is the canonical, project-agnostic composition layer for shared agent roles and Outfitter development resources. Consumers use it as an Outfitter settings source and keep their own domain context, skills, and operating rules locally.

- Contribution rules (scope, change standards): @CONTRIBUTING.md
- Adoption flow (personal layer → local checkouts → projects): @docs/runbook/agent.dotfile-development.md
- Machine setup, live source graph, validation, and publish workflow: @docs/runbook/local-development.md

## Precedence: last entry wins

Outfitter merges `profile_sources` last-wins: the **last** entry in the YAML list is the **highest** precedence for same-ID profiles and skills. `ncrmro/.agents` is always listed last so personal roles and skills override everything else. New or modified resources start here, then trickle upstream: generalize them, move them to the owning repository, and behavior stays identical because this layer keeps overriding until the upstream version lands.

## Source graph

Highest precedence first (note this is the **reverse** of YAML list order, where highest comes last):

| Source | Published catalog root | Typical local source | Resources used here |
| --- | --- | --- | --- |
| `ncrmro/.agents` | `profiles/` | `~/repos/ncrmro/.agents/profiles` | Personal overrides and shared roles |
| `ai-outfitter/actions` | `.outfitter/` | Primary checkout or a clean main worktree's `.outfitter/` | `outfitter-actions` skill |
| `ai-outfitter/outfitter` | `.outfitter/` on current main | Checkout-dependent: `.outfitter/` on main; some development branches publish from `code/cli/` | Local `outfitter` skill |
| `ai-outfitter/community-profiles` | `profiles/` | `~/repos/unsupervised/ai-outfitters/community-profiles/profiles` | Community roles such as `github-actions` |
| `ai-outfitter/default-profiles` | `profiles/` | `~/repos/unsupervised/ai-outfitters/default-profiles/profiles` | Default roles and `pyramid-principle` |

The `founder` profile selects the local `outfitter` skill. The actions source exists for `outfitter-actions` development, but its checked-out skill uses glob references Outfitter 0.10.0 cannot materialize; select it only with a compatible Outfitter checkout or release.

## Two equivalent source graphs

RFC [ai-outfitter/outfitter#165](https://github.com/ai-outfitter/outfitter/issues/165) proposes replacing profile-era `.outfitter` configuration with the Dotagents `.agents` protocol; until it lands, treat profile-era files as transitional. This repository provides:

1. `settings.yml` — pinned published GitHub revisions for portable consumers and CI.
2. Ignored `local/settings.yml` — the same graph as live local checkouts for development.

A consumer commits the flattened published graph, then writes its own ignored `.outfitter/local/settings.yml` for live edits. The local file MUST be a regular file, not a symlink, and it replaces `profile_sources` wholesale — Outfitter does not recursively load `settings.yml` from a profile source. Keep both graphs in the same precedence order. See the runbook for the concrete templates and commands.

## Repository layout

- `settings.yml` — portable, pinned remote source graph.
- `profiles/` — project-agnostic roles owned by this repository.
- `local/settings.yml` — ignored machine-local live source graph.
- `docs/runbook/` — operational runbooks, starting with local development.
- `README.md` — user-facing index.
- `CONTRIBUTING.md` — scope rules and change standards.
- `*.generated-system-prompt.md` — ignored validation artifacts.
