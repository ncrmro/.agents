---
name: project-context-handoff
description: Human-invoked. Create or refresh the TASKS.md / PLAN.md / CHANGELOG.md handoff triad so another agent can resume cold. Focused extract of project-planning's handoff-files convention.
disable-model-invocation: true
---

# Project context handoff

Bring the durable working context up to date so a fresh agent (or human) can
resume without re-deriving anything. This is the focused, on-demand version of
the handoff-files convention documented in the `project-planning` skill —
invoke it when wrapping up a session, before switching machines, or whenever
someone asks to "hand off" or "save context".

## The triad

Three plain-markdown files on the same time axis a git graph uses:

| file | question | lifecycle |
| --- | --- | --- |
| `PLAN.md` | what we intend, and in what order | living — future work / pointer to the canonical plan report + repo map |
| `TASKS.md` | what is happening right now | living — live/blocked work, newest first |
| `CHANGELOG.md` | what already landed | append-only — commits + runtime state |

PLAN = future, TASKS = present, CHANGELOG = past.

## Level

The triad lives at **repo level** (version-controlled, one repo's work) or
**org level** (a workspace dir holding several checkouts, often not a git
repo, as shared cross-repo scratch), and both can be true at once. Decide the
level from where the work spans, and put `PLAN.md` where the owning AGENTS.md
points.

## Procedure

1. **Scope.** Determine the level (repo vs org) and locate any existing triad.
   If none exists, create it at the level the work spans.
2. **Gather state, don't guess.** For each touched repo: `git log --oneline`
   since the last CHANGELOG entry, current branch/worktree/dirty state, open
   PRs/issues, and any non-code runtime state that matters (a deployed host's
   running generation, a paused external job). Read the actual state; never
   infer commit hashes or task status.
3. **Write each file for a cold reader** who did not watch the session:
   - **TASKS.md** — lead with live/blocked items. For each: exact current
     state, the *next concrete step*, and gotchas already hit (so the next
     agent doesn't repeat them). Then open-not-started, then a one-line
     "done today" pointer to CHANGELOG.
   - **PLAN.md** — the projected graph, or a short pointer to the canonical
     committed report (`docs/reports/*-plan.md`) plus the repo map (which
     work lives in which repo, with branches/PRs) and the abbreviated
     release graph.
   - **CHANGELOG.md** — append per-repo landed work with commit hashes and
     runtime state. Do not rewrite existing entries.
4. **Record the convention** in the owning `AGENTS.md` if not already there:
   which files exist, at which level, and that they are updated in the same
   turn as the work they describe.
5. **Report** the level chosen, the files written, and the single most
   important resume action (usually the top TASKS.md item).

## Rules

- Accuracy over completeness: a wrong commit hash or a stale "done" is worse
  than an omission. Verify against `git` and live state.
- Keep it scannable — a cold agent should find the next action in seconds.
- If the workspace dir is not a git repo, say so in the files (shared scratch,
  not version-controlled) and do not attempt to commit them.
- Full rationale, the two-level model, and the plan-graph notation live in the
  `project-planning` skill; this skill is the fast path to keeping the triad
  fresh, not a replacement for it.
