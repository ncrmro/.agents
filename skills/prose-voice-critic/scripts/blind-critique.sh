#!/bin/sh
# blind-critique.sh — critique a document against its author's style guide using
# a CLI subagent with a fully replaced system prompt.
#
# The blind pass runs from an empty directory so no CLAUDE.md/AGENTS.md, memory
# index, or git status is injected. That injection happens on the USER side from
# the cwd, so replacing the system prompt alone does NOT prevent it.
#
# usage:
#   blind-critique.sh --guide <style-guide.md> --doc <document.md> [options]
#
# options:
#   --context <text>   one or two lines of genre context (audience, length)
#   --task <text>      extra task lines (e.g. "run section 8 item by item")
#   --persona <file>   critic system prompt (default: ../references persona)
#   --model <model>    default: sonnet
#   --both             also run a primed pass from $PWD and diff the two
#   --out <dir>        write outputs here (default: a temp dir, path printed)
set -eu

SELF_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
GUIDE=""; DOC=""; CONTEXT=""; EXTRA_TASK=""; PERSONA=""; MODEL="sonnet"
BOTH=0; OUT=""
ORIGIN=$(pwd -P)

while [ $# -gt 0 ]; do
	case $1 in
		--guide)   GUIDE=$2; shift 2 ;;
		--doc)     DOC=$2; shift 2 ;;
		--context) CONTEXT=$2; shift 2 ;;
		--task)    EXTRA_TASK=$2; shift 2 ;;
		--persona) PERSONA=$2; shift 2 ;;
		--model)   MODEL=$2; shift 2 ;;
		--both)    BOTH=1; shift ;;
		--out)     OUT=$2; shift 2 ;;
		-h|--help) sed -n '2,20p' "$0"; exit 0 ;;
		*) echo "unknown option: $1" >&2; exit 2 ;;
	esac
done

[ -n "$GUIDE" ] && [ -r "$GUIDE" ] || { echo "--guide must be a readable file" >&2; exit 2; }
[ -n "$DOC" ]   && [ -r "$DOC" ]   || { echo "--doc must be a readable file" >&2; exit 2; }
command -v claude >/dev/null 2>&1 || { echo "claude CLI not on PATH" >&2; exit 2; }

[ -n "$OUT" ] || OUT=$(mktemp -d)
mkdir -p "$OUT"

# Extract the persona from the reference doc's first fenced block unless given.
if [ -z "$PERSONA" ]; then
	REF="$SELF_DIR/../references/critic-system-prompt.md"
	[ -r "$REF" ] || { echo "no --persona and cannot read $REF" >&2; exit 2; }
	PERSONA="$OUT/persona.txt"
	awk '/^```text$/{f=1;next} /^```$/{if(f)exit} f' "$REF" > "$PERSONA"
	[ -s "$PERSONA" ] || { echo "could not extract persona from $REF" >&2; exit 2; }
fi

PROMPT="$OUT/prompt.txt"
{
	echo "Below are two documents: the author's style guide, then a piece written for him."
	echo
	echo "=============== DOCUMENT 1: THE AUTHOR'S STYLE GUIDE ==============="
	echo
	cat "$GUIDE"
	echo
	echo "=============== DOCUMENT 2: THE PIECE UNDER REVIEW ==============="
	echo
	[ -n "$CONTEXT" ] && { echo "$CONTEXT"; echo; }
	cat "$DOC"
	echo
	echo "=============== YOUR TASK ==============="
	echo
	echo "Critique the piece against the style guide. Work section by section."
	echo "Judge any repeated structure — headings, section openers — as a set."
	[ -n "$EXTRA_TASK" ] && echo "$EXTRA_TASK"
} > "$PROMPT"

run_pass() {
	# $1 = label, $2 = directory to run from
	( cd "$2" && claude -p "$(cat "$PROMPT")" \
		--model "$MODEL" --system-prompt "$(cat "$PERSONA")" ) > "$OUT/critique-$1.md" 2>&1
	echo "$OUT/critique-$1.md"
}

BLIND_DIR="$OUT/blind-cwd"
mkdir -p "$BLIND_DIR"
echo "running blind pass (model: $MODEL, cwd: empty)..." >&2
run_pass blind "$BLIND_DIR" >/dev/null

# Contamination check: a blind critique must not know project vocabulary. This
# is a heuristic, not proof — it looks for the shapes project context adds.
if grep -qiE '\[\[|CLAUDE\.md|AGENTS\.md|memory|\.claude/' "$OUT/critique-blind.md"; then
	echo "WARNING: blind critique mentions project-context vocabulary." >&2
	echo "         Inspect it — the run may not have been blind." >&2
fi

if [ "$BOTH" -eq 1 ]; then
	echo "running primed pass (cwd: $ORIGIN)..." >&2
	run_pass primed "$ORIGIN" >/dev/null
	echo >&2
	echo "Compare the two. Where they disagree is the finding:" >&2
	echo "  both condemn  -> real, fix it" >&2
	echo "  blind only    -> you were too close to see it" >&2
	echo "  primed only   -> it matched your stated complaint; re-examine" >&2
fi

echo >&2
echo "output: $OUT" >&2
cat "$OUT/critique-blind.md"
