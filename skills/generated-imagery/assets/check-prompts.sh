#!/usr/bin/env bash
# Flag prose in a prompt or fragment that an image model cannot act on.
#
#   IMAGESET_ROOT=. ./check-prompts.sh
#
# Five checks, each one a habit that crept back in and had to be cleaned out by
# hand: provenance, justification by precedent, a comparison standing where a
# figure should be, a prohibition where a description would do, and a fragment
# nothing references. The script reports; it never edits. Some hits are correct
# prose, so judgement stays with the reader.
#
# KEEP THE CHECKS AND THE RULES IN STEP. A check that enforces a superseded rule
# flags every good line, and a reader who learns to ignore one check ignores all
# of them. When you change a rule, change its check in the same pass.
set -uo pipefail

ROOT="${IMAGESET_ROOT:-$PWD}"
cd "$ROOT" || exit 1

FILES=$(find design.md prompts fragments -name '*.md' 2>/dev/null | sort)
[ -n "$FILES" ] || { echo "no prompts or fragments under $ROOT" >&2; exit 1; }

hits=0
report() {
	local label=$1 pattern=$2 exempt=${3:-}
	local found
	found=$(printf '%s\n' "$FILES" | xargs grep -nEi "$pattern" 2>/dev/null || true)
	# A third argument exempts any hit whose own line also matches it.
	[ -n "$exempt" ] && found=$(printf '%s\n' "$found" | grep -Ev "$exempt" || true)
	[ -z "$found" ] && return
	printf '\n%s\n' "$label"
	printf '%s\n' "$found" | sed 's/^/  /'
	hits=$((hits + $(printf '%s\n' "$found" | wc -l)))
}

report "provenance - state the figure, not where it came from" \
	'datasheet|vendor[- ]spec|per the .* standard|source: |according to|\bcited\b|\bsee the .*\.md'

# Precedent names are per domain. Add the names your subject matter keeps
# reaching for: real products, prior models, historical examples.
report "justification - a model cannot draw a precedent" \
	'\bprecedent\b|as (used|flown|shipped|built) (on|by)|the industry standard|every (documented|known)|just like the'

# A comparison to a familiar object is wanted where it calibrates a figure and
# unwanted where it replaces one, so this check reads the whole line. A
# comparison that shares its line with a measurement is a scale anchor and
# passes. A comparison standing alone is the failure and is reported.
measured='[0-9]+(\.[0-9]+)?[[:space:]]*(mm|cm|m|km|kg|g|lb|in|ft|px|pt|%|°|:1)\b|#[0-9a-fA-F]{3,8}\b|\bx[0-9]'
report "vague comparison - give the figure, then anchor it" \
	'roughly|approximately|about the size|a (little|bit) (larger|smaller|longer|wider|thicker)|somewhat|fairly|several' \
	"$measured"

report "prohibition - state what is there instead" \
	'\bnever\b|\bnot too\b|must not|do not (draw|show|render)|avoid |\bno [a-z]+ (is|are|sits|appears)'

report "choice - one answer per prompt, or two prompts" \
	'\beither\b|\bor a\b|\bor an\b| may (be|have|sit|appear)|optionally'

# A fragment nothing references is a fragment nobody maintains. A subject
# composes its own components, so a reference can sit a level or more below a
# prompt. Walk the whole tree, not only the top of it.
orphans=""
for f in fragments/*.md; do
	[ -e "$f" ] || continue
	n=$(basename "$f")
	printf '%s\n' "$FILES" | xargs grep -q "@[^[:space:]]*$n" 2>/dev/null \
		|| orphans="$orphans$f"$'\n'
done
if [ -n "$orphans" ]; then
	printf '\nunreferenced fragment - delete it or point a prompt at it\n'
	printf '%s' "$orphans" | sed 's/^/  /'
	hits=$((hits + 1))
fi

if [ "$hits" -eq 0 ]; then
	echo "clean"
else
	printf '\n%d line(s) to look at\n' "$hits"
fi
