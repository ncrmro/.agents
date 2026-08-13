# Shared agent configuration

This repository is the canonical, project-agnostic Outfitter v1 layer for shared agents, skills, and development resources. It is linked at `~/.agents`; consuming projects keep domain context, skills, and operating rules in their own `.agents/` trees.

- Contribution rules (scope, change standards): @CONTRIBUTING.md
- Adoption flow, machine setup, live source overrides, and validation: @docs/runbook/agent.dotfile-development.md

## Always work on `main`

Commit straight to `main`. No feature branches, and no worktrees.

This is not a style preference. `~/.agents` is a live symlink into this
checkout, so whatever branch is checked out is what every agent on the machine
loads right now. Checking out a branch silently changes the global catalog:
a skill committed on another branch disappears from `~/.agents/skills` until
you switch back, and an agent mid-task loses it without any error. Work sitting
on a branch also configures nothing, because nothing reads that branch.

If a change is risky, make it small and land it; do not park it on a branch.

## Native v1 precedence

Outfitter resolves resources from highest to lowest precedence: project `.agents/`, global `~/.agents/`, then `sources` in listed order. This repository is the global layer, so its agents and skills override configured remote catalogs. New or modified resources start here, then trickle upstream after they have proved reusable.

## Source graph

Highest precedence first:

| Layer                             | Root                                                | Resources used here                    |
| --------------------------------- | --------------------------------------------------- | -------------------------------------- |
| Consuming project                 | `<project>/.agents/`                                | Project-specific context and overrides |
| `ncrmro/.agents`                  | This repository                                     | Personal agents and skills             |
| `ai-outfitter/default-profiles`   | Repository root at the ref pinned in `settings.yml` | Published v1 defaults                  |
| `ai-outfitter/community-profiles` | Transitively pinned by `default-profiles`           | Published community agents and skills  |

`settings.local.yml` may replace `sources` with local checkout paths for live development. Keep machine-specific paths out of committed settings.

## Migration compatibility

Outfitter 1.x (1.0.2 or later) implements the native Dotagents model from [RFC #165](https://github.com/ai-outfitter/outfitter/issues/165). The active identities live in `agents/<slug>/agent.md`, and `settings.yml` uses `default_agent`, `default_harness`, and `sources`.

The `profiles/` files and legacy keys in `settings.yml` are a frozen compatibility snapshot for pre-v1 Outfitter: edit `agents/` and `skills/` only, do not sync changes back into the snapshot, and never make native v1 agents depend on it.

## Sessions are recorded

On `ncrmro-workstation` and `ncrmro-laptop`, Claude Code sessions are recorded
to a self-hosted Pensieve sink. The collector is installed at managed scope in
`/etc/claude-code/managed-settings.d/`, so it applies to every session on those
machines regardless of which agent, persona, or project layer is active — this
one included. It cannot be turned off from a settings file.

What leaves the machine: one record per session start (working directory and
invocation arguments) and one per tool call (tool name, input, output, error
flag), grouped against a commit whenever `HEAD` moves. Prompts, model responses,
diffs, and transcript contents are not sent — the transcript is referenced by
path only.

Configured in ks-config; runbook at `~/repos/ncrmro/ks-config/docs/pensieve.md`.

## Repository layout

- `agents/` — native v1 identities and their loadouts.
- `skills/` — native v1 skills.
- `personas/` — cross-project persona documents, appended to a reviewer at
  launch (see `personas/README.md`). Not a resource type Outfitter resolves;
  plain Markdown referenced by absolute path, so it works from any directory.
  Project-specific personas stay in that project's `docs/personas/`.
- `settings.yml` — v1 defaults and published source graph.
- `settings.local.yml` — ignored machine-local source overrides.
- `profiles/` — frozen pre-v1 snapshot (see Migration compatibility).
- `docs/runbook/` — adoption and local-development guidance.
- `README.md` — user-facing index.
- `CONTRIBUTING.md` — scope rules and change standards.
- `*.generated-system-prompt.md` — ignored validation artifacts.
