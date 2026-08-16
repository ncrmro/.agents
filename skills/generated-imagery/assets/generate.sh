#!/usr/bin/env bash
# Generate candidate renders for one prompt in an image set.
#
#   IMAGESET_ROOT=. ./generate.sh hero 3 "optional extra instruction"
#
# The script freezes the prompt tree, then runs one backend call per variant, in
# parallel. Each call makes one image and exits. Nothing reviews its own output;
# a separate pass does that. Variant suffixes continue from what already exists,
# so a rerun never overwrites an earlier batch.
#
#   ./generate.sh --model <name> hero 3     # a different model
#   ./generate.sh --effort medium hero 3    # more reasoning
#   ./generate.sh --no-fast hero 3          # standard service tier
set -euo pipefail

ROOT="${IMAGESET_ROOT:-$PWD}"
SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/out"
BACKEND="${IMAGESET_BACKEND:-codex}"   # tags every file name, so two backends can coexist
SIZE="${IMAGESET_SIZE:-1024x768}"

MODEL=""
EFFORT="low"      # the model chooses nothing here, so reasoning buys no pixels
RUN_FAST=true

usage() {
	cat >&2 <<'USAGE'
usage: generate.sh [options] <prompt-id> [count] [extra instruction]

  --model <name>    backend model. Default: the backend's own default.
  --effort <level>  reasoning effort: none, low, medium, high. Default: low.
  --no-fast         drop the fast service tier.

Environment:
  IMAGESET_ROOT     the image set directory. Default: the current directory.
  IMAGESET_BACKEND  tag written into each file name. Default: codex.
  IMAGESET_SIZE     pixel size passed to the backend. Default: 1024x768.
USAGE
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
		--model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
		--effort)  EFFORT="${2:?--effort needs a value}"; shift 2 ;;
		--no-fast) RUN_FAST=false; shift ;;
		-h|--help) usage ;;
		--*)       echo "unknown option: $1" >&2; usage ;;
		*)         break ;;
	esac
done

ID="${1:-}"
[ -n "$ID" ] || usage
COUNT="${2:-3}"
EXTRA="${3:-}"

[ -f "$ROOT/prompts/$ID.md" ] || { echo "no prompt file for $ID" >&2; exit 1; }
mkdir -p "$OUT"

HASH="$(IMAGESET_ROOT="$ROOT" "$SCRIPTS/snapshot-prompt.py" "$ID")"

# ---------------------------------------------------------------------------
# THE BACKEND CALL. This is the one function to swap for a different tool.
#
# Reference implementation: `codex exec`, which resolves the @ references in the
# prompt file itself, reads every referenced file, and calls its image tool. A
# backend that does not resolve references must be handed the concatenated
# snapshot at $OUT/prompts/$HASH/ instead.
#
# Contract: generate exactly one image at $2, write a JSON object matching
# generate-schema.json to $3, and send all chatter to stdout.
# ---------------------------------------------------------------------------
generate_one() {
	local prompt_id="$1" image_path="$2" result_json="$3"

	local opts=(-c model_reasoning_effort="$EFFORT")
	$RUN_FAST && opts+=(--enable fast_mode -c service_tier="fast")
	[ -n "$MODEL" ] && opts+=(-m "$MODEL")

	codex exec --skip-git-repo-check --sandbox workspace-write "${opts[@]}" \
		--output-schema "$SCRIPTS/generate-schema.json" \
		--output-last-message "$result_json" \
		"The prompt is @prompts/$prompt_id.md

Generate one image with the image tool, size $SIZE, saved as $image_path

$EXTRA

Then exit. Another agent reviews it." </dev/null
}

# Next free suffixes: A-Z, then AA-ZZ. A single letter alphabet runs out on a
# well iterated image, and the run then reports success having made nothing.
# Extend the alphabet, and fail loudly when the suffixes still run short.
suffixes=()
for S in {A..Z} {A..Z}{A..Z}; do
	[ -e "$OUT/$ID-$S-$BACKEND.png" ] && continue
	suffixes+=("$S")
	[ "${#suffixes[@]}" -eq "$COUNT" ] && break
done
[ "${#suffixes[@]}" -eq "$COUNT" ] || {
	echo "only ${#suffixes[@]} free suffixes for $ID, wanted $COUNT" >&2; exit 1; }

names=()
for S in "${suffixes[@]}"; do names+=("$ID-$S-$BACKEND.png"); done

echo "generating $COUNT for $ID  (prompt tree $HASH)  -> ${names[*]}" >&2

RUN_MODEL="${MODEL:-default}"
cd "$ROOT"

pids=()
for n in "${names[@]}"; do
	date +%s > "$OUT/.start-${n%.png}"
	generate_one "$ID" "out/$n" "$OUT/.result-${n%.png}.json" \
		> "$OUT/.log-${n%.png}-$HASH.txt" 2>&1 &
	pids+=($!)
done

status=0
for p in "${pids[@]}"; do wait "$p" || status=1; done

# What each run cost, recorded beside what it produced. Two rounds are only
# comparable when the settings behind both are on disk. The fragment list is the
# run's own account of what it read, so a tree that failed to resolve shows up
# here and not only in the picture.
for n in "${names[@]}"; do
	result="$OUT/.result-${n%.png}.json"
	started="$(cat "$OUT/.start-${n%.png}" 2>/dev/null || echo 0)"
	took=$(( $(date +%s) - started ))
	[ "$started" -eq 0 ] && took=-1

	# Backend specific. codex prints "tokens used" and then the count on the next
	# line. Another backend's log needs its own parse here, next to the backend
	# call it belongs to. Null is a valid value; a wrong number is not.
	tokens="$(grep -A1 -m1 '^tokens used' "$OUT/.log-${n%.png}-$HASH.txt" 2>/dev/null \
		| tail -1 | tr -cd '0-9')"

	IMAGE="$n" PROMPT="$HASH" AT="$(date -Iseconds)" OUT="$OUT" \
	RUN_MODEL="$RUN_MODEL" EFFORT="$EFFORT" RUN_FAST="$RUN_FAST" TOOK="$took" \
	TOKENS="${tokens:-}" \
	python3 - "$result" <<'PY' >> "$OUT/provenance.jsonl"
import json, os, sys
row = {
    "image": os.environ["IMAGE"],
    "prompt": os.environ["PROMPT"],
    "at": os.environ["AT"],
    "model": os.environ["RUN_MODEL"],
    "effort": os.environ["EFFORT"],
    "fast": os.environ["RUN_FAST"] == "true",
    "seconds": int(os.environ["TOOK"]),
}
row["on_disk"] = os.path.exists(os.path.join(os.environ["OUT"], row["image"]))
try:
    with open(sys.argv[1]) as handle:
        result = json.load(handle)
    row.update({k: result[k] for k in ("saved", "size", "fragments", "error") if k in result})
except Exception as problem:
    row["error"] = f"no structured result: {problem}"
print(json.dumps(row))
PY
	rm -f "$result" "$OUT/.start-${n%.png}"
done

for n in "${names[@]}"; do
	[ -e "$OUT/$n" ] && echo "$n" || { echo "MISSING $n" >&2; status=1; }
done
exit "$status"
