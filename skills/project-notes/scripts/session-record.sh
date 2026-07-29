#!/usr/bin/env bash
# Record a session in a project's SESSIONS.md from JSON the agent generates.
# Keyed on the session id: recording the same session again rewrites its own
# entry and leaves every other one alone.
# Run session-record.sh --help for usage.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/project-page.sh
. "$here/lib/project-page.sh"
# shellcheck source=lib/require.sh
. "$here/lib/require.sh"

schema="$here/../schemas/session-entry.schema.json"

usage() {
  cat <<'EOF'
session-record.sh — write a SESSIONS.md entry from JSON, for the project-notes
skill.

Usage:
  session-record.sh SLUG < entry.json
  session-record.sh SLUG --json FILE
  session-record.sh SLUG --dry-run < entry.json    print, do not write
  session-record.sh --schema                       print the input schema
  session-record.sh -h | --help

You generate the JSON; this validates it and owns the file. Never edit
SESSIONS.md by hand — that is how fields go missing and how the entry below
gets changed by accident.

  {
    "session":  "d9386ef9-…",       key: same string every time
    "status":   "in-progress",      or done (default), or abandoned
    "date":     "2026-07-29",
    "subject":  "what this session did",
    "agent":    "claude-code · opus-5",
    "resume":   "claude --resume d9386ef9-…",   omit if not resumable
    "repo":     "owner/name",
    "branch":   "main",
    "worktree": "~/repos/owner/name",
    "head":     "1332984 refactor(deploy): …",
    "work":     "what changed and what it proves, including what it did not",
    "refs":     "[Issue #42](url) · [PR #13](url)",
    "next":     "the first thing to do on resume"
  }

The session id is the key. Record early with status in-progress, then record
again as the work lands: the entry is rewritten in place, keeping its position,
and no other entry is touched. A new session id adds a new entry at the top.

Run --schema for the field rules, including which are required and why.
EOF
}

case "${1:-}" in
  -h | --help | "")
    usage
    exit 0
    ;;
  --schema)
    cat "$schema"
    exit 0
    ;;
esac

slug=$1
shift
json_in='' dry_run=false
while [ $# -gt 0 ]; do
  case "$1" in
    --json) json_in=${2:-}; shift 2 || exit 1 ;;
    --dry-run) dry_run=true; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "session-record.sh: unknown argument $1" >&2; exit 2 ;;
  esac
done

require_tool jq \
  'nix profile install nixpkgs#jq' \
  'brew install jq' \
  'apt install jq'

# The validator is an implementation detail: callers pass JSON, not schemas.
require_tool check-jsonschema \
  'nix profile install nixpkgs#check-jsonschema' \
  'pipx install check-jsonschema' \
  'brew install check-jsonschema'
validate=(check-jsonschema)

sessions="$NOTES/wiki/projects/$slug/SESSIONS.md"
[ -f "$sessions" ] || {
  echo "session-record.sh: no $sessions" >&2
  echo "       create it from assets/SESSIONS.template.md first" >&2
  exit 2
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if [ -n "$json_in" ]; then
  cat "$json_in" >"$work/entry.json"
else
  cat >"$work/entry.json"
fi
[ -s "$work/entry.json" ] || {
  echo "session-record.sh: no JSON on stdin (see --help)" >&2
  exit 2
}
jq -e . "$work/entry.json" >/dev/null 2>&1 || {
  echo "session-record.sh: input is not valid JSON, so nothing was written." >&2
  jq . "$work/entry.json" 2>&1 | head -3 >&2
  exit 1
}

if ! "${validate[@]}" --schemafile "$schema" "$work/entry.json" >"$work/out" 2>&1; then
  echo "session-record.sh: the entry is not valid, so nothing was written." >&2
  sed -e "s#$work/entry.json#entry#g" -e '/^$/d' "$work/out" >&2
  exit 1
fi

# One field at a time. A single tab-separated read is tempting, but bash merges
# consecutive tab delimiters, so an omitted optional field silently shifts every
# value after it.
field_of() { jq -r --arg k "$1" '.[$k] // ""' "$work/entry.json"; }
session=$(field_of session)
status=$(field_of status)
date=$(field_of date)
subject=$(field_of subject)
agent=$(field_of agent)
resume=$(field_of resume)
repo=$(field_of repo)
branch=$(field_of branch)
worktree=$(field_of worktree)
head_commit=$(field_of head)
body_work=$(field_of work)
body_refs=$(field_of refs)
body_next=$(field_of next)
[ -n "$status" ] || status=done

heading="## [$date] $subject"
[ "$status" = done ] || heading="$heading — $status"

identity="- agent: $agent · session \`$session\`"
if [ -n "$resume" ]; then
  identity="$identity · resume \`$resume\`"
else
  identity="$identity · not resumable"
fi

{
  printf '%s\n\n' "$heading"
  printf '%s\n' "$identity"
  printf -- '- branch: `%s` in %s · worktree `%s`\n' "$branch" "$repo" "$worktree"
  printf -- '- head: `%s`\n' "$head_commit"
  printf -- '- work: %s\n' "$body_work"
  printf -- '- refs: %s\n' "$body_refs"
  printf -- '- next: %s\n' "$body_next"
} >"$work/entry.md"

if [ "$dry_run" = true ]; then
  cat "$work/entry.md"
  exit 0
fi

# Entry boundaries: each starts at a `## [` heading and runs to the next one.
mapfile -t starts < <(grep -n '^## \[' "$sessions" | cut -d: -f1)
total=$(wc -l <"$sessions")

replace_from=0 replace_to=0
for index in "${!starts[@]}"; do
  from=${starts[$index]}
  if [ $((index + 1)) -lt ${#starts[@]} ]; then
    to=$((starts[index + 1] - 1))
  else
    to=$total
  fi
  if sed -n "${from},${to}p" "$sessions" | grep -qF "session \`$session\`"; then
    replace_from=$from
    replace_to=$to
    break
  fi
done

if [ "$replace_from" -gt 0 ]; then
  # Update in place, keeping this entry's position and every other entry byte
  # for byte. The blank line before the next entry is re-emitted so spacing
  # stays uniform however many trailing blanks the old entry had.
  {
    [ "$replace_from" -gt 1 ] && head -n "$((replace_from - 1))" "$sessions"
    cat "$work/entry.md"
    if [ "$replace_to" -lt "$total" ]; then
      printf '\n'
      tail -n "+$((replace_to + 1))" "$sessions"
    fi
  } >"$work/next.md"
  action=updated
else
  # A session not seen before: insert above the newest entry.
  if [ ${#starts[@]} -gt 0 ]; then
    insert=${starts[0]}
    {
      head -n "$((insert - 1))" "$sessions"
      cat "$work/entry.md"
      printf '\n'
      tail -n "+$insert" "$sessions"
    } >"$work/next.md"
  else
    { cat "$sessions"; printf '\n'; cat "$work/entry.md"; } >"$work/next.md"
  fi
  action=added
fi

cp "$work/next.md" "$sessions"
echo "session-record.sh: $action [$date] $subject ($status) in wiki/projects/$slug/SESSIONS.md"
