#!/usr/bin/env bash
# try-product.sh — put a persona in front of the running product.
#
# Launches headless Chrome with remote debugging on a URL and prints the
# instruction block for the agent to *use* the product in character. The agent
# drives it with its own browser tools (Chrome DevTools/CDP on the printed
# port, or its playwright/claude-in-chrome MCP tools) — this script sets the
# stage and defines what to report.
#
#   try-product.sh URL [--persona FILE] [--task "..."] [--port N] [--keep]
#
#   --persona  path to a docs/personas/*.md file; its role/org/bio are quoted
#              into the instructions so the agent acts as that person
#   --task     the specific decision to reach (default: form an opinion)
#   --port     remote debugging port (default 9222)
#   --keep     leave Chrome running after printing (default: kill on exit)
#
# Exits non-zero if the URL is not reachable — a persona cannot evaluate a
# page that never loaded, and a hallucinated review is worse than none.
set -euo pipefail

url="" persona="" task="" port=9222 keep=0

die() { printf 'try-product.sh: %s\n' "$*" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --persona) [ $# -ge 2 ] || die "--persona needs a value"; persona="$2"; shift 2 ;;
    --task)    [ $# -ge 2 ] || die "--task needs a value";    task="$2";    shift 2 ;;
    --port)    [ $# -ge 2 ] || die "--port needs a value";    port="$2";    shift 2 ;;
    --keep)    keep=1; shift ;;
    -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        die "unknown argument: $1 (try --help)" ;;
    *)         [ -z "$url" ] || die "unexpected argument: $1"; url="$1"; shift ;;
  esac
done

[ -n "$url" ] || die "a URL is required (try --help)"
[ -z "$persona" ] || [ -f "$persona" ] || die "persona not found: $persona"

chrome=""
for c in chromium chromium-browser google-chrome-stable google-chrome; do
  if command -v "$c" >/dev/null 2>&1; then chrome="$c"; break; fi
done
[ -n "$chrome" ] || die "no chromium/chrome on PATH"

# Fail loudly rather than reviewing a dead page.
if command -v curl >/dev/null 2>&1; then
  curl --silent --show-error --fail --location --max-time 15 --output /dev/null "$url" \
    || die "URL is not reachable: $url (is the dev server running?)"
fi

profile="$(mktemp -d)"
cleanup() {
  [ "$keep" -eq 1 ] && return 0
  [ -n "${chrome_pid:-}" ] && kill "$chrome_pid" 2>/dev/null || true
  rm -rf "$profile"
}
trap cleanup EXIT

"$chrome" \
  --headless=new \
  --disable-gpu \
  --no-first-run \
  --remote-debugging-port="$port" \
  --user-data-dir="$profile" \
  --window-size=1440,900 \
  "$url" >/dev/null 2>&1 &
chrome_pid=$!

# Give CDP a moment, then confirm it actually came up.
for _ in $(seq 1 20); do
  if curl --silent --fail --max-time 2 "http://127.0.0.1:$port/json/version" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done
curl --silent --fail --max-time 2 "http://127.0.0.1:$port/json/version" >/dev/null 2>&1 \
  || die "Chrome did not expose CDP on port $port"

printf '=== SESSION ===\n'
printf 'url:      %s\n' "$url"
printf 'cdp:      http://127.0.0.1:%s  (pid %s)\n' "$port" "$chrome_pid"
printf 'profile:  %s\n\n' "$profile"

printf '=== IN CHARACTER ===\n'
if [ -n "$persona" ]; then
  cat "$persona"
else
  printf 'No persona supplied. Act as a first-time user with no context,\n'
  printf 'and say so in the report.\n'
fi

cat <<INSTRUCTIONS

=== INSTRUCTIONS FOR THE AGENT ===

You are the person described above. Use the product at the URL — click, type,
navigate, follow what interests you. Attach to the CDP endpoint above or use
your browser tools. Do not read the source to work out what it does; if the
interface does not tell you, that is the finding.

Task: ${task:-form an opinion on whether this is worth your time}

Report, briefly and in character:

1. First impression — what you thought this was, within ten seconds.
2. What you tried — in order, including anything you expected and did not find.
3. Where you got stuck, misread something, or lost trust.
4. What you would tell the team — the single change with the most effect.
5. Would you come back? One line, and why.

Rules:
- Report only what you observed. If a page failed to load, say that and stop.
- Quote the interface's own words when you criticise them.
- Separate "confusing" from "broken" — they get fixed by different people.

Feedback is commentary until it changes a document. Anything worth keeping
belongs in the persona's bio, a requirement, a milestone demo script, or a
report addendum.
INSTRUCTIONS

if [ "$keep" -eq 1 ]; then
  printf '\nChrome left running (pid %s). Kill it when done: kill %s\n' "$chrome_pid" "$chrome_pid"
else
  printf '\nChrome stops when this script exits. Use --keep to hold the session open.\n'
fi
