#!/usr/bin/env bash
# Delegate one lane to a headless worker in its own git worktree.
#
#   delegate.sh <type>/<slug> "<task prompt>" [--agent codex|claude|outfitter]
#                                             [--base <branch>]     # default origin/main
#                                             [--land pr|direct|none]
#                                             [--existing]          # reuse existing worktree/branch
#                                             [--autonomous]
#
# Pipeline (synchronous inside the script — the ORCHESTRATOR runs this script as
# a background shell task and watches its log; see SKILL.md):
#   1. worktree   ../<project>.worktrees/<type>/<slug> off <base> (fresh JIT cut,
#                 or reused with --existing)
#   2. TASKS.md   seeded from the skill's assets/TASKS.template.md
#   3. worker     codex (sol model) by default, runs the task headless in the worktree
#   4. gate       claude -p "/simplify", then claude -p "/code-review" in a fix
#                 loop until a pass produces no new commits
#   5. land       pr (squash-merged PR) | direct (squash to base) | none
#   6. cleanup    remove the worktree, delete the merged branch
#
# Resume a stalled worker from the worktree instead of restarting the lane:
#   codex:  codex exec resume --last -C <worktree>
#   claude: (cd <worktree> && claude -p --resume)
#
# SAFETY: by default the worker keeps its normal approval prompts; --autonomous
# disables them FOR THE WORKER ONLY inside this throwaway worktree. Landing is
# never silent: it requires an explicit --land value or an interactive choice,
# and defaults to leaving the branch unmerged.
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template="$skill_dir/assets/TASKS.template.md"

die() { printf 'delegate: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---- args -------------------------------------------------------------------
branch="${1:-}"; shift || true
task="${1:-}"; shift || true
agent="codex"; base="origin/main"; land=""; autonomous=0; existing=0
while [ $# -gt 0 ]; do
  case "$1" in
    --agent) agent="${2:-}"; shift 2 ;;
    --base) base="${2:-}"; shift 2 ;;
    --land) land="${2:-}"; shift 2 ;;
    --existing) existing=1; shift ;;
    --autonomous) autonomous=1; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done
[ -n "$branch" ] || die "usage: delegate.sh <type>/<slug> \"<task>\" [--agent ...] [--land ...]"
[ -n "$task" ]   || die "a task prompt is required"
case "$branch" in
  feat/*|fix/*|chore/*|milestone/*) : ;;
  *) die "branch must be <type>/<slug> with type feat|fix|chore|milestone" ;;
esac

# ---- worker invocation ------------------------------------------------------
# Approval-bypass flags are opt-in via --autonomous and confined to the worker
# in this throwaway worktree; the default keeps each agent's normal prompts on.
codex_model="${CODEX_MODEL:-gpt-5.6-sol}"
claude_auto=(); codex_auto=()
if [ "$autonomous" = 1 ]; then
  claude_auto=(--permission-mode bypassPermissions)
  codex_auto=(${CODEX_AUTONOMOUS_FLAGS:---full-auto})
fi
run_agent() {
  local prompt="$1"
  case "$agent" in
    codex)     codex exec -m "$codex_model" --sandbox workspace-write -C "$PWD" "${codex_auto[@]}" "$prompt" ;;
    claude)    claude -p "$prompt" "${claude_auto[@]}" ;;
    outfitter) outfitter run --agent claude -- -p "$prompt" "${claude_auto[@]}" ;;
    *) die "unknown agent: $agent" ;;
  esac
}
have "$agent" || die "$agent not found on PATH"
have claude || die "claude not found on PATH (needed for /simplify and /code-review)"

# ---- worktree ---------------------------------------------------------------
repo_root="$(git rev-parse --show-toplevel)" || die "not in a git repo"
project="$(basename "$repo_root")"
git -C "$repo_root" rev-parse --verify --quiet "$base" >/dev/null || die "base branch '$base' not found"
worktree_rel="$repo_root/../$project.worktrees/$branch"
if [ "$existing" = 1 ]; then
  [ -d "$worktree_rel" ] || die "--existing given but no worktree at $worktree_rel"
else
  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    die "branch '$branch' already exists — pass --existing, or pick another slug"
  fi
  echo "delegate: creating worktree $worktree_rel (branch $branch off $base)" >&2
  git -C "$repo_root" worktree add -b "$branch" "$worktree_rel" "$base"
fi
worktree="$(cd "$worktree_rel" && pwd)"   # normalize

cleanup_done=0
cleanup_worktree() {
  [ "$cleanup_done" = 1 ] && return; cleanup_done=1
  echo "delegate: removing worktree $worktree" >&2
  git -C "$repo_root" worktree remove --force "$worktree" 2>/dev/null || true
}

# ---- seed TASKS.md ----------------------------------------------------------
if [ -f "$template" ] && [ ! -f "$worktree/TASKS.md" ]; then
  cp "$template" "$worktree/TASKS.md"
  printf '\n- [ ] %s\n' "$task" >> "$worktree/TASKS.md"
fi

# ---- run the pipeline in the worktree --------------------------------------
# Both subshells run </dev/null: this script is normally itself backgrounded,
# and any child left reading the inherited pipe (codex exec, claude -p) hangs
# forever waiting on stdin. The land prompt below deliberately keeps stdin.
(
  cd "$worktree"
  echo "delegate: [$agent] working the task..." >&2
  run_agent "$task"
) </dev/null

# Skip the gate entirely when the worker produced no commits — otherwise a
# no-op lane burns a /simplify plus up to three /code-review invocations.
if git -C "$worktree" diff --quiet "$base"...HEAD 2>/dev/null; then
  echo "delegate: no commits on $branch — nothing to land." >&2
  cleanup_worktree; exit 0
fi

# The /code-review pass runs headless via claude -p: the code-review skill is
# disable-model-invocation, so the slash command is the only scriptable entry.
# Fix loop: re-run code-review until a pass adds no new commits (max 3 passes).
gate_status=0
(
  cd "$worktree"
  echo "delegate: /simplify" >&2
  claude -p "/simplify" "${claude_auto[@]}" ${GATE_MODEL:+--model "$GATE_MODEL"}
  for pass in 1 2 3; do
    before="$(git rev-parse HEAD)"
    echo "delegate: /code-review (pass $pass)" >&2
    claude -p "/code-review" "${claude_auto[@]}" ${GATE_MODEL:+--model "$GATE_MODEL"}
    [ "$(git rev-parse HEAD)" = "$before" ] && exit 0
  done
  exit 42   # still churning after 3 passes
) </dev/null || gate_status=$?
if [ "$gate_status" = 42 ]; then
  echo "delegate: code-review still churning after 3 passes — NOT landing; branch left at $worktree for human review." >&2
  land=none
elif [ "$gate_status" != 0 ]; then
  die "gate failed (exit $gate_status)"
fi

# ---- land (asked each run; never a silent push) ----------------------------
if [ -z "$land" ]; then
  if [ -t 0 ]; then
    printf 'Land %s how?\n  1) pr      (squash-merged PR; use for shared repos)\n  2) direct  (squash-merge to %s and push; personal repos only)\n  3) none    (leave the branch, do not merge)\n> ' "$branch" "$base" >&2
    read -r reply
    case "$reply" in 1|pr) land=pr ;; 2|direct) land=direct ;; *) land=none ;; esac
  else
    echo "delegate: non-interactive and no --land given; leaving branch '$branch' unmerged." >&2
    land=none
  fi
fi

case "$land" in
  pr)
    git -C "$worktree" push -u origin "$branch"
    ( cd "$worktree" && gh pr create --fill && { gh pr merge --squash || gh pr merge --squash --auto; } )
    echo "delegate: PR squash-merge requested. If GitHub reports CONFLICTING, rebase in the worktree, re-gate, push --force-with-lease, and merge again." >&2
    ;;
  direct)
    local_base="${base#origin/}"
    git -C "$repo_root" switch "$local_base"
    git -C "$repo_root" pull --ff-only origin "$local_base" 2>/dev/null || true
    git -C "$repo_root" merge --squash "$branch"
    # Squash message: first lane commit's subject as the headline, the rest as
    # the body — not git's default "Squashed commit of the following" dump.
    subject="$(git -C "$repo_root" log --reverse --format=%s "$local_base..$branch" | head -n1)"
    body="$(git -C "$repo_root" log --reverse --format='- %s' "$local_base..$branch" | tail -n +2)"
    git -C "$repo_root" commit -m "$subject" ${body:+-m "$body"}
    git -C "$repo_root" push
    cleanup_worktree
    git -C "$repo_root" branch -D "$branch" 2>/dev/null || true
    ;;
  none)
    echo "delegate: branch '$branch' left in place at $worktree" >&2
    ;;
  *) die "unknown --land value: $land (want pr|direct|none)" ;;
esac
