#!/usr/bin/env bash
# page-feedback.sh — screenshot a page and hand the image to a persona.
#
# The cheaper half of the feedback loop: no interaction, just "what does this
# look like to someone who is not us". Captures a full-page screenshot and
# prints the instruction block for the agent to read the image and critique it
# in character.
#
#   page-feedback.sh URL [--persona FILE] [--out PATH] [--width N] [--height N]
#                        [--full] [--wait MS]
#
#   --persona  path to a docs/personas/*.md file
#   --out      screenshot path (default: mktemp .../page-<slug>.png)
#   --width    viewport width  (default 1440)
#   --height   viewport height (default 900)
#   --full     capture the whole scrollable page, not just the viewport
#   --wait     ms to wait for rendering before capture (default 1200)
#
# Exits non-zero if the URL is unreachable or the screenshot is missing/empty,
# so an agent is never asked to review an image that is not there.
set -euo pipefail

url="" persona="" out="" width=1440 height=900 full=0 wait_ms=1200

die() { printf 'page-feedback.sh: %s\n' "$*" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --persona) [ $# -ge 2 ] || die "--persona needs a value"; persona="$2"; shift 2 ;;
    --out)     [ $# -ge 2 ] || die "--out needs a value";     out="$2";     shift 2 ;;
    --width)   [ $# -ge 2 ] || die "--width needs a value";   width="$2";   shift 2 ;;
    --height)  [ $# -ge 2 ] || die "--height needs a value";  height="$2";  shift 2 ;;
    --wait)    [ $# -ge 2 ] || die "--wait needs a value";    wait_ms="$2"; shift 2 ;;
    --full)    full=1; shift ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        die "unknown argument: $1 (try --help)" ;;
    *)         [ -z "$url" ] || die "unexpected argument: $1"; url="$1"; shift ;;
  esac
done

[ -n "$url" ] || die "a URL is required (try --help)"
[ -z "$persona" ] || [ -f "$persona" ] || die "persona not found: $persona"

if [ -z "$out" ]; then
  slug="$(printf '%s' "$url" | sed -e 's#^https\?://##' -e 's/[^A-Za-z0-9]\+/-/g' \
          -e 's/^-\+//' -e 's/-\+$//' | cut -c1-60)"
  out="$(mktemp -d)/page-${slug:-capture}.png"
fi

chrome=""
for c in chromium chromium-browser google-chrome-stable google-chrome; do
  if command -v "$c" >/dev/null 2>&1; then chrome="$c"; break; fi
done
[ -n "$chrome" ] || die "no chromium/chrome on PATH"

if command -v curl >/dev/null 2>&1; then
  curl --silent --show-error --fail --location --max-time 15 --output /dev/null "$url" \
    || die "URL is not reachable: $url (is the dev server running?)"
fi

profile="$(mktemp -d)"
trap 'rm -rf "$profile"' EXIT

args=(
  --headless=new --disable-gpu --no-first-run --hide-scrollbars
  --user-data-dir="$profile"
  --window-size="$width,$height"
  --virtual-time-budget="$wait_ms"
  --screenshot="$out"
)
[ "$full" -eq 1 ] && args+=(--screenshot-full-page)

"$chrome" "${args[@]}" "$url" >/dev/null 2>&1 || true

[ -s "$out" ] || die "screenshot was not produced: $out"

bytes=$(wc -c < "$out" | tr -d ' ')

printf '=== CAPTURE ===\n'
printf 'url:   %s\n' "$url"
printf 'image: %s (%s bytes, %sx%s%s)\n\n' \
  "$out" "$bytes" "$width" "$height" "$([ "$full" -eq 1 ] && printf ', full page')"

printf '=== IN CHARACTER ===\n'
if [ -n "$persona" ]; then
  cat "$persona"
else
  printf 'No persona supplied. React as a first-time visitor with no context,\n'
  printf 'and say so in the report.\n'
fi

cat <<INSTRUCTIONS

=== INSTRUCTIONS FOR THE AGENT ===

Read the image above with your file-reading tool — actually look at it. You
are the person described. You have not seen this product before and you are
not reading its source.

Report, briefly and in character:

1. What you think this page is for, from the image alone.
2. The first thing your eye lands on, and whether that is the right thing.
3. Anything you cannot read, cannot tell apart, or would misinterpret —
   including contrast, density, and numbers with no unit or context.
4. What is missing that you expected at this stage.
5. The single change with the most effect.

Rules:
- Describe only what is visible. Do not infer behaviour you cannot see, and do
  not compensate for the design by reasoning about what it probably does.
- Quote on-screen text when you criticise it.
- If the page looks broken or empty, say so plainly — that is the finding.

Feedback is commentary until it changes a document. Anything worth keeping
belongs in the persona's bio, a requirement, a milestone demo script, or a
report addendum.
INSTRUCTIONS
