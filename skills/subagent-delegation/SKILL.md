---
name: subagent-delegation
description: Use when delegating a task to a subagent, or when running a task that AGENTS.md says should be completed in its own worktree. Covers picking a headless worker (claude/codex/outfitter), the typed worktree + zellij tab, its local TASKS.md, the /simplify + /code-review gate, and landing per-run (direct squash or PR + automerge).
---

# Subagent delegation

Unless the request explicitly says otherwise, a task is completed by a **headless
agent working in its own git worktree**, run in its own Zellij tab, and tracked
in a `TASKS.md` local to that worktree. This keeps the `main` checkout and any
in-flight human work untouched while an agent runs.

The worker is one of three runtimes, **chosen per task** (ask when it isn't
specified):

| Choice | Invocation | Notes |
| --- | --- | --- |
| `claude` | `claude -p "<task>"` | Claude Code headless; blocks until the turn ends. |
| `codex` | `codex exec "<task>"` | Codex non-interactive. |
| `outfitter` | `outfitter run --agent claude -- -p "<task>"` | Profile-wrapped launch; Outfitter's `run` drives **pi or claude**, not codex. |

The review passes always use `claude -p` (they are Claude Code slash commands),
regardless of which runtime did the primary work.

`TASKS.md` is **gitignored** — a local scratchpad, one per worktree, not a
committed artifact. Seed it from [`assets/TASKS.template.md`](assets/TASKS.template.md).
Because `-p`/`exec` block until the turn ends, **process exit is the done-signal**
— `TASKS.md` is the human-readable progress view, never a watch loop.

## The helper script

[`scripts/delegate.sh`](scripts/delegate.sh) runs the whole pipeline
synchronously:

```sh
scripts/delegate.sh <type>/<slug> "<task prompt>" [--agent claude|codex|outfitter]
                                                  [--base <branch>]      # default: main
                                                  [--land direct|pr|none]
                                                  [--autonomous]
                                                  [--no-close-tab]
```

It: creates the worktree off `<base>`, seeds `TASKS.md`, names the current Zellij
tab after the slug, runs the chosen agent on the task, runs `claude -p
"/simplify"` then `claude -p "/code-review"`, asks how to land, then cleans up.
Run it **inside a fresh Zellij tab** so the work is observable — the script
renames that tab and closes it on cleanup:

```sh
zellij action new-tab --cwd "$(git rev-parse --show-toplevel)"
# then, in the new tab (the script renames the tab to the slug):
scripts/delegate.sh feat/crop-imagery "Add crop imagery to the gallery" --agent claude
```

Zellij is for **observation only**: `new-tab`/`run` return immediately and cannot
wait for the child, so control flow lives in the script (which blocks naturally
on each `-p`/`exec`), and Zellij just names and later closes the tab.

## Safety: autonomy and landing

- **Approvals stay on by default.** An unattended worker may pause or decline
  sensitive actions. `--autonomous` disables approval prompts **for the worker
  only, inside the throwaway worktree** — use it only for runs you are willing to
  leave unattended. Never wire an approval-disabled agent to push on its own.
- **Landing is asked every run and never silent.** The merge/push happens only on
  an explicit choice — an interactive prompt, or an explicit `--land`. With no
  choice in non-interactive use, the branch is left unmerged.
  - `direct` — `git merge --squash` into `main` + push. **Personal repos only.**
  - `pr` — push, `gh pr create --fill`, `gh pr merge --squash --auto`. **Required
    for shared/org repos** (e.g. `ai-outfitter/*`), where CI / branch protection /
    the merge queue is the real gate. See the `platform` skill's
    `references/automerge-merge-queues.md` for enabling automerge and merge queues.

## Worktree layout

Worktrees sort next to their checkout under a sibling directory named after the
repository:

```text
../<project>.worktrees/<type>/<slug>
```

- `<project>` — the repository's directory name (basename of the repo root).
- `<type>` — one of `feat`, `fix`, `chore`, `milestone` (matches branch and commit type).
- `<slug>` — short kebab-case name. The branch matches the `type/slug` path.

## Procedure

Prefer `scripts/delegate.sh`. When running the steps by hand, the order is:

1. **Create the worktree** at `../<project>.worktrees/<type>/<slug>` off `main`.
2. **Seed `TASKS.md`** from `assets/TASKS.template.md` at the worktree root. The
   worker keeps it current — its own checklist, not a shared backlog.
3. **Run the chosen worker** on the task in the worktree; wait for it to exit.
4. **`claude -p "/simplify"`** — clean up the diff (reuse, simplification, altitude).
5. **`claude -p "/code-review"`** — check the diff for correctness bugs; address findings.
6. **Land per the chosen policy** (`direct` or `pr`), then remove the worktree and
   close the Zellij tab.

Never land the branch without the `/simplify` and `/code-review` steps first.

## When to work directly in the main checkout

Only when the user explicitly asks for it — for example, a quick edit that is not
worth a worktree. In that case the main checkout's own (gitignored) `TASKS.md` is
the scratchpad.

## Boundaries

- `TASKS.md` (any worktree) — a local, gitignored, agent-maintained checklist.
- Durable project plans, requirements, and milestone definitions → `docs/`
  (see `AGENTS.md` and the `reports` skill), not `TASKS.md`.
