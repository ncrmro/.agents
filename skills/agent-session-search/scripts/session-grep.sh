#!/usr/bin/env bash
# Rank agent session logs by how often a term appears. Prints "count<TAB>path",
# highest first. Usage: session-grep.sh <term> [codex|claude|all] [limit]
set -u
set +o pipefail  # head(1) closes the pipe early; SIGPIPE upstream is expected
term="${1:?usage: session-grep.sh <term> [codex|claude|all] [limit]}"
scope="${2:-all}"
limit="${3:-15}"

roots=()
[[ "$scope" == "codex"  || "$scope" == "all" ]] && roots+=("$HOME/.codex/sessions")
[[ "$scope" == "claude" || "$scope" == "all" ]] && roots+=("$HOME/.claude/projects")

for r in "${roots[@]}"; do
  [[ -d "$r" ]] || continue
  grep -rlZi --include='*.jsonl' -- "$term" "$r" 2>/dev/null \
  | xargs -0 -r grep -ci -- "$term" 2>/dev/null
done \
| sed 's/:\([0-9]*\)$/\t\1/' \
| awk -F'\t' '{print $2"\t"$1}' \
| sort -rn \
| head -n "$limit"
