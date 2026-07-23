#!/usr/bin/env bash
# Delegate a task to a headless agent working in its own git worktree.
#
#   delegate.sh <type>/<slug> "<task prompt>" [--agent claude|codex|outfitter]
#                                             [--base <branch>]
#                                             [--land direct|pr|none]
#                                             [--autonomous]
#                                             [--no-close-tab]
#
# Pipeline (synchronous — the call blocks until the pipeline finishes):
#   1. worktree   ../<project>.worktrees/<type>/<slug> off <base> (default main)
#   2. TASKS.md   seeded from the skill's assets/TASKS.template.md
#   3. agent      the chosen agent runs the task headless (-p / exec) in the worktree
#   4. review     claude -p "/simplify" then claude -p "/code-review", in the worktree
#   5. land       ASK per run (direct squash to main | PR + automerge | none)
#   6. cleanup    remove the worktree, delete the merged branch, close the zellij tab
#
# SAFETY: by default the worker keeps its normal approval prompts, so an
# unattended run may pause or decline sensitive actions. Passing --autonomous
# disables those approvals FOR THE WORKER ONLY, and only inside this throwaway
# worktree — use it just for runs you are willing to leave unattended. Landing
# never happens silently: it requires an explicit --land value or an interactive
# choice, and defaults to leaving the branch unmerged.
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template="$skill_dir/assets/TASKS.template.md"

die() { printf 'delegate: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---- args -------------------------------------------------------------------
branch="${1:-}"; shift || true
task="${1:-}"; shift || true
agent=""; base="main"; land=""; autonomous=0; close_tab=1
while [ $# -gt 0 ]; do
  case "$1" in
    --agent) agent="${2:-}"; shift 2 ;;
    --base) base="${2:-}"; shift 2 ;;
    --land) land="${2:-}"; shift 2 ;;
    --autonomous) autonomous=1; shift ;;
    --no-close-tab) close_tab=0; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done
[ -n "$branch" ] || die "usage: delegate.sh <type>/<slug> \"<task>\" [--agent ...] [--land ...]"
[ -n "$task" ]   || die "a task prompt is required"
case "$branch" in
  feat/*|fix/*|chore/*|milestone/*) : ;;
  *) die "branch must be <type>/<slug> with type feat|fix|chore|milestone" ;;
esac

# ---- agent selection --------------------------------------------------------
if [ -z "$agent" ]; then
  if [ -t 0 ]; then
    printf 'Which agent should do the work?\n  1) claude    (claude -p)\n  2) codex     (codex exec)\n  3) outfitter (outfitter run --agent claude)\n> ' >&2
    read -r reply
    case "$reply" in
      1|claude) agent=claude ;;
      2|codex) agent=codex ;;
      3|outfitter) agent=outfitter ;;
      *) die "unrecognized choice: $reply" ;;
    esac
  else
    die "non-interactive: pass --agent claude|codex|outfitter"
  fi
fi

# Approval-bypass flags are opt-in via --autonomous and confined to the worker
# in this throwaway worktree; the default keeps each agent's normal prompts on.
claude_auto=(); codex_auto=()
if [ "$autonomous" = 1 ]; then
  claude_auto=(--permission-mode bypassPermissions)
  codex_auto=(${CODEX_AUTONOMOUS_FLAGS:---full-auto})
fi
run_agent() {
  local prompt="$1"
  case "$agent" in
    claude)    claude -p "$prompt" "${claude_auto[@]}" ;;
    codex)     codex exec "${codex_auto[@]}" "$prompt" ;;
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
if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
  die "branch '$branch' already exists — pick another slug or clean it up first"
fi
worktree_rel="$repo_root/../$project.worktrees/$branch"
echo "delegate: creating worktree $worktree_rel (branch $branch off $base)" >&2
git -C "$repo_root" worktree add -b "$branch" "$worktree_rel" "$base"
worktree="$(cd "$worktree_rel" && pwd)"   # normalize

cleanup_done=0
cleanup_worktree() {
  [ "$cleanup_done" = 1 ] && return; cleanup_done=1
  echo "delegate: removing worktree $worktree" >&2
  git -C "$repo_root" worktree remove --force "$worktree" 2>/dev/null || true
}

# ---- zellij tab (observation only) -----------------------------------------
renamed_tab=0
if [ -n "${ZELLIJ:-}" ] && have zellij; then
  zellij action rename-tab "${branch##*/}" 2>/dev/null && renamed_tab=1 || true
fi
close_zellij_tab() {
  [ "$renamed_tab" = 1 ] && [ "$close_tab" = 1 ] && have zellij && zellij action close-tab 2>/dev/null || true
}

# ---- seed TASKS.md ----------------------------------------------------------
if [ -f "$template" ]; then
  cp "$template" "$worktree/TASKS.md"
  printf '\n- [ ] %s\n' "$task" >> "$worktree/TASKS.md"
fi

# ---- run the pipeline in the worktree --------------------------------------
(
  cd "$worktree"
  echo "delegate: [$agent] working the task..." >&2
  run_agent "$task"
  echo "delegate: /simplify" >&2
  claude -p "/simplify" "${claude_auto[@]}"
  echo "delegate: /code-review" >&2
  claude -p "/code-review" "${claude_auto[@]}"
)

if git -C "$worktree" diff --quiet "$base"...HEAD 2>/dev/null; then
  echo "delegate: no commits on $branch — nothing to land." >&2
  cleanup_worktree; close_zellij_tab; exit 0
fi

# ---- land (asked each run; never a silent push) ----------------------------
if [ -z "$land" ]; then
  if [ -t 0 ]; then
    printf 'Land %s how?\n  1) direct  (squash-merge to %s and push)\n  2) pr      (open PR + gh automerge after CI)\n  3) none    (leave the branch, do not merge)\n> ' "$branch" "$base" >&2
    read -r reply
    case "$reply" in 1|direct) land=direct ;; 2|pr) land=pr ;; *) land=none ;; esac
  else
    echo "delegate: non-interactive and no --land given; leaving branch '$branch' unmerged." >&2
    land=none
  fi
fi

case "$land" in
  direct)
    git -C "$repo_root" switch "$base"
    git -C "$repo_root" merge --squash "$branch"
    git -C "$repo_root" commit --no-edit
    git -C "$repo_root" push
    cleanup_worktree
    git -C "$repo_root" branch -D "$branch" 2>/dev/null || true
    close_zellij_tab
    ;;
  pr)
    git -C "$worktree" push -u origin "$branch"
    ( cd "$worktree" && gh pr create --fill && gh pr merge --squash --auto )
    echo "delegate: PR opened with automerge; worktree kept until CI merges. Remove with:" >&2
    echo "  git -C \"$repo_root\" worktree remove \"$worktree\"" >&2
    close_zellij_tab
    ;;
  none)
    echo "delegate: branch '$branch' left in place at $worktree" >&2
    ;;
  *) die "unknown --land value: $land (want direct|pr|none)" ;;
esac
