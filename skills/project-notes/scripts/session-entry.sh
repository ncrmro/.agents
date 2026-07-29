#!/usr/bin/env bash
# Print a prefilled SESSIONS entry for the current agent session: date, repo,
# branch, worktree, and resume handle. Prints to stdout only — never writes to
# the vault, so no half-filled entry can land there via auto-commit.
# Run session-entry.sh --help for usage.
set -uo pipefail

usage() {
  cat <<'EOF'
session-entry.sh — emit a SESSIONS.md entry skeleton for the work happening
in the current session, for the project-notes skill.

Usage:
  session-entry.sh                        detect everything it can from the cwd
  session-entry.sh --session ID           the harness session id (see below)
  session-entry.sh --agent NAME           e.g. "claude-code · opus-5", "codex"
  session-entry.sh --subject "TEXT"       entry heading
  session-entry.sh -h | --help

Session id: read from CLAUDE_CODE_SESSION_ID when set, overridden by --session.
It is also the UUID directory in the Claude Code scratchpad path:

  /tmp/claude-$UID/<encoded-cwd>/<SESSION-ID>/scratchpad

Pass it explicitly on a harness that exports nothing.

A resume command is emitted only for a harness known to support one. Anything
else gets a placeholder: fill it in or replace it with "not resumable". Do not
invent a handle.

Repo, branch, and worktree come from the current directory when it is a git
checkout. Anything undetected is emitted as a <placeholder>.
EOF
}

agent='' session='' subject=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    --agent) agent=${2:-}; shift 2 || exit 1 ;;
    --session) session=${2:-}; shift 2 || exit 1 ;;
    --subject) subject=${2:-}; shift 2 || exit 1 ;;
    *) echo "error: unknown argument '$1'" >&2; usage >&2; exit 1 ;;
  esac
done

session=${session:-${CLAUDE_CODE_SESSION_ID:-}}
subject=${subject:-'<short subject — what this session did>'}

repo='<owner/repo>' branch='<branch>' worktree='<path>' head='<sha> <subject>'
if git rev-parse --git-dir >/dev/null 2>&1; then
  origin=$(git remote get-url origin 2>/dev/null || true)
  if [ -n "$origin" ]; then
    r=${origin%.git}; r=${r#*://}; r=${r#*@}; r=${r/:/\/}
    repo=$(printf '%s\n' "$r" | rev | cut -d/ -f1,2 | rev)
  fi
  branch=$(git branch --show-current 2>/dev/null)
  [ -n "$branch" ] || branch="detached at $(git rev-parse --short HEAD 2>/dev/null)"
  worktree=$(git rev-parse --show-toplevel 2>/dev/null)
  head=$(git log -1 --format='%h %s' 2>/dev/null)
fi

# Only harnesses with a known resume command get one — see --help.
case "$agent" in
  *codex*) resume="codex resume ${session:-<session-id>}" ;;
  *claude*) resume="claude --resume ${session:-<session-id>}" ;;
  *) resume='<resume command — or "not resumable">' ;;
esac

cat <<EOF
## [$(date +%F)] $subject

- agent: ${agent:-<harness · model>} · session \`${session:-<session-id>}\` · resume \`$resume\`
- branch: \`$branch\` in $repo · worktree \`$worktree\`
- head: \`$head\`
- work: <what actually changed, and what it proves — evidence class included>
- refs: [Issue #<n>](<url>) · [PR #<n>](<url>)
- next: <what is unfinished, and the first thing to do on resume>
EOF
