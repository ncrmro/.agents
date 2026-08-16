---
name: subagent-delegation
description: Use when delegating a task to a subagent, or when running a task that AGENTS.md says should be completed in its own worktree. Covers the codex (sol) background-shell worker, the JIT worktree cut from origin/main, watching and resuming stalled workers, the /simplify + /code-review gate, and landing per-lane by squash-merged PR until a whole queue is merged.
---

# Subagent delegation

Unless the request explicitly says otherwise, a task is completed by a **headless
worker running as a background shell process in its own git worktree**, watched by
the orchestrator via its log, and tracked in a `TASKS.md` local to the
orchestrator's checkout. This keeps `main` and any in-flight human work untouched
while workers run, and lets many lanes run concurrently.

**Claude permission trap:** `--permission-mode dontAsk` is not automatic
approval. It rejects actions that need approval. A headless Claude worker or
reviewer SHOULD use `--permission-mode auto`. Use `bypassPermissions` only when
the user explicitly authorizes a full permission bypass in an isolated worktree.

## The verified flow (one lane)

1. **Cut a fresh JIT worktree off `origin/main`** at
   `../<project>.worktrees/<type>/<slug>` (branch `<type>/<slug>`). Always cut
   fresh just-in-time — if work already exists in an old worktree or branch, move
   it in by copy or cherry-pick rather than rebasing stale history; the goal is
   well-defined self-contained commits.
2. **Implementation — codex, sol model, background shell task.** Launch
   `codex exec -m "${CODEX_MODEL:-gpt-5.6-sol}" --sandbox workspace-write -C <worktree> "<task>"`
   as a background process with stdout captured to a log (the model is a
   default, overridable via `CODEX_MODEL`; delegate.sh honors the same var). Watch the log /
   completion signal; never block a foreground terminal on it. Include in the
   prompt: the branch's state, exact commit message(s) wanted, "do not push",
   and a final self-verification (status + log) to report.
3. **Quality gate — separate review pass, also background shell tasks, in order:**
   - `/simplify`: either a claude subagent that invokes the `simplify` skill in
     the worktree, or `claude -p "/simplify" --permission-mode auto` run
     from the worktree. Fixes are committed (amend single-commit lanes; separate
     `refactor: simplify per review` commit otherwise).
   - `/code-review`: **must** be `claude -p "/code-review" --permission-mode
     auto` run from inside the worktree — the `code-review` skill is
     `disable-model-invocation` (the Skill tool refuses it) and the `review`
     skill is GitHub-PR-only. CONFIRMED findings get fixed and committed;
     PLAUSIBLE/advisory findings are reported to the coordinator, not churned on.
   - **Fix loop:** if code-review produced fixes, re-run it until it reports no
     new confirmed findings. Never land without both passes clean.
4. **Land — squash-merged PR, per-lane, no pause once the gate is clean**
   (authorization rules live in Safety below):
   `git push -u origin <branch> && gh pr create --fill && gh pr merge --squash`
   (add `--auto` where branch protection gates on CI — setup procedure in the
   `platform` skill's `references/automerge-merge-queues.md`). If GitHub reports
   CONFLICTING, the base moved: hand the worker a rebase/merge-resolution task
   (background codex again), re-verify, force-push `--force-with-lease`, merge.
5. **Bookkeeping:** promote the lane's glyph in the plan file (`○ → ◉ → ●` + the
   merge sha), remove the worktree, delete the branch. Then start the next lane;
   loop until the whole queue is merged. Finish a multi-lane queue by verifying
   the deployment of `main` actually works.

**Stdin trap:** a backgrounded `codex exec` with no stdin redirect hangs
forever "Reading additional input from stdin..." — it appends piped stdin to
the prompt. Always launch background workers with `</dev/null` (delegate.sh
does this). A worker whose worktree stays clean for a long time with no log
output is almost certainly stdin-hung: kill it and relaunch, don't wait.

## Claude permission modes

- `auto` — default for unattended headless workers and review passes. Claude
  classifies each operation and automatically approves suitable operations.
- `acceptEdits` — accepts file edits. It is not general automatic approval.
- `dontAsk` — never prompts and rejects operations that require approval. Do not
  use it as an automatic mode.
- `bypassPermissions` — bypasses all Claude permission checks. Use it only after
  explicit user authorization and only in an isolated worktree.

For an adversarial read-only Opus review, make both the available-tool set and
the allowed-tool set explicit:

```sh
claude -p "<review prompt>" \
  --model opus \
  --effort high \
  --permission-mode auto \
  --no-session-persistence \
  --tools "Read,Grep,Glob" \
  --allowedTools "Read,Grep,Glob"
```

Claude's permission mode does not control the orchestrator's filesystem or
command sandbox. If an outer approval service rejects the process launch,
changing Claude's permission mode cannot approve that outer operation.

## Watching and resuming workers

Background workers are shell processes — the orchestrator watches the log file
and is notified on exit. If a worker dies, hangs, or the machine restarts, resume
it **from the worktree** instead of restarting the task from scratch:

- codex: `codex exec resume --last -C <worktree>` (or `codex exec resume <id>`)
- claude: `claude -p --resume` from the worktree (or `--continue`)

Subagents must **never background their own children**: a subagent that launches
`claude -p` in the background ends its turn and the pipeline stalls. Review/child
commands inside a worker run in the foreground of that worker; only the
orchestrator backgrounds things.

## Parallelism and ordering

Lanes with no file overlap run concurrently (each its own worktree + background
worker). Lanes that share files, or are stacked, land strictly in order. Since
every lane lands by squash-merged PR onto a moving `origin/main`, expect late
lanes to need a conflict pass — that is normal, delegate it (step 4).

## Safety: autonomy and landing

- Headless Claude workers use `--permission-mode auto`. A full permission bypass
  (`--permission-mode bypassPermissions` / `--full-auto`) requires explicit
  authorization and MUST remain confined to the throwaway worktree.
- Landing is never silent: it happens only when the run was explicitly
  authorized to auto-land (e.g. the user approved "auto-merge when the gate is
  clean") or on an explicit per-lane choice. Shared/org repos always land via
  PR (never a direct push to main); personal repos may squash direct.
- Verification is real or it didn't happen: never substitute a mocked success,
  and report gate findings (including skipped advisories) up to the user.

## Helper scripts

[`scripts/agent-bg`](scripts/agent-bg) runs any agent command in the
background and leaves simple shell state for monitoring. It does not create a
worktree, run gates, commit, push, or land; it only detaches stdin, captures
stdout/stderr, writes pid/exit/command files under
`${AGENT_BG_DIR:-/tmp/agent-bg}`, and prints monitor commands. Use it for ad hoc
implementation-only dispatch, review passes, or any backend that is already in
the right working directory:

```sh
scripts/agent-bg <name> <command> [args...]
scripts/agent-bg-status <name> [--follow]

# Example: implementation-only Codex worker in an existing worktree.
scripts/agent-bg fix-persist-sessions \
  codex exec -m "${CODEX_MODEL:-gpt-5.6-sol}" \
    --sandbox workspace-write -C ../repo.worktrees/fix/persist-sessions \
    "$(cat task.md)"
```

[`scripts/delegate.sh`](scripts/delegate.sh) remains the full lane workflow
(worktree → codex worker → /simplify → /code-review loop → land). The
orchestrator launches the whole script as a background shell task and watches
its log:

```sh
scripts/delegate.sh <type>/<slug> "<task prompt>" [--agent codex|claude|outfitter]
                                                  [--base <branch>]      # default: origin/main
                                                  [--land pr|direct|none]
                                                  [--existing]           # reuse an existing worktree/branch
                                                  [--autonomous]
```

`TASKS.md` is **gitignored** — a local scratchpad, one per worktree, seeded from
[`assets/TASKS.template.md`](assets/TASKS.template.md); the plan/queue lives in
the orchestrator's own TASKS.md, where lane glyphs are promoted in place.

## Worktree layout

```text
../<project>.worktrees/<type>/<slug>
```

`<type>` — `feat` | `fix` | `chore` | `milestone` (matches branch and commit
type); `<slug>` — short kebab-case. The branch matches the `type/slug` path.

## When to work directly in the main checkout

Only when the user explicitly asks for it — e.g. a quick edit not worth a
worktree. Then the main checkout's own (gitignored) `TASKS.md` is the scratchpad.

## Boundaries

- `TASKS.md` (any worktree) — local, gitignored, agent-maintained.
- Durable plans, requirements, milestone definitions → `docs/` (see `AGENTS.md`
  and the `reports` skill), not `TASKS.md`.
