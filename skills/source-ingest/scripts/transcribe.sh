#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
profile="${SOURCE_INGEST_NIX_PROFILE:-$HOME/.nix-profile}"
model_dir="${WHISPER_MODEL_DIR:-$HOME/.cache/whisper}"
input=
output_base=
model=
tinydiarize=0
allow_cpu=0

usage() {
  cat <<'EOF'
Usage: transcribe.sh INPUT --output-base BASE [options]

Options:
  --model FILE       whisper.cpp ggml model (default: best installed model)
  --tinydiarize      Enable English speaker-turn markers
  --allow-cpu        Explicitly permit CPU fallback
  -h, --help         Show help

Outputs: BASE.txt, BASE.srt, BASE.json, BASE.whisper.log, and
BASE.transcription.json. Existing outputs are never overwritten.
EOF
}

fail() {
  printf 'transcribe: %s\n' "$1" >&2
  exit "${2:-1}"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-base|--model)
      [ "$#" -ge 2 ] || fail "$1 requires a value" 2
      if [ "$1" = --output-base ]; then output_base=$2; else model=$2; fi
      shift 2
      ;;
    --tinydiarize) tinydiarize=1; shift ;;
    --allow-cpu) allow_cpu=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) fail "unknown option: $1" 2 ;;
    *)
      [ -z "$input" ] || fail "exactly one INPUT is required" 2
      input=$1
      shift
      ;;
  esac
done

[ -n "$input" ] || { usage >&2; exit 2; }
[ -f "$input" ] || fail "input does not exist: $input" 2
[ -n "$output_base" ] || fail "--output-base is required" 2

export PATH="$profile/bin:$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$profile/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

doctor_args=(--json)
[ "$allow_cpu" -eq 0 ] || doctor_args+=(--allow-cpu)
doctor_json="$("$script_dir/toolchain-doctor.sh" "${doctor_args[@]}")" ||
  fail "toolchain is not ready; run setup-tools.sh or authorize --allow-cpu" 3

if [ -z "$model" ]; then
  if [ "$tinydiarize" -eq 1 ]; then
    model_names=(ggml-small.en-tdrz.bin)
  else
    model_names=(ggml-large-v3.bin ggml-small.en-tdrz.bin)
  fi
  for name in "${model_names[@]}"; do
    if [ -s "$model_dir/$name" ]; then model="$model_dir/$name"; break; fi
  done
fi
[ -n "$model" ] && [ -s "$model" ] ||
  fail "no model found; pass --model or run setup-tools.sh" 2

if [ "$tinydiarize" -eq 1 ] &&
  [[ "$(basename "$model")" != *tdrz* ]]; then
  fail "--tinydiarize requires a tinydiarize model" 2
fi

mkdir -p "$(dirname "$output_base")"
artifacts=(
  "$output_base.txt" "$output_base.srt" "$output_base.json"
  "$output_base.whisper.log" "$output_base.transcription.json"
)
for artifact in "${artifacts[@]}"; do
  [ ! -e "$artifact" ] || fail "refusing to overwrite: $artifact" 2
done

scratch="$(mktemp -d)"
cleanup() {
  [ -d "${scratch:-}" ] && rm -rf -- "$scratch"
}
trap cleanup EXIT
wav="$scratch/audio.wav"

ffmpeg -y -loglevel error -i "$input" -vn -ar 16000 -ac 1 "$wav"

whisper_args=(
  -m "$model" -f "$wav"
  --output-txt --output-srt --output-json --output-file "$output_base"
)
[ "$tinydiarize" -eq 0 ] || whisper_args+=(--tinydiarize)

whisper-cli "${whisper_args[@]}" >"$output_base.whisper.log" 2>&1 ||
  fail "whisper-cli failed; see $output_base.whisper.log"

for artifact in "$output_base.txt" "$output_base.srt" "$output_base.json"; do
  [ -s "$artifact" ] || fail "expected output is missing: $artifact"
done

backend="$(jq -r '.whisper.backend' <<<"$doctor_json")"
device="$(jq -r '.whisper.device' <<<"$doctor_json")"
runtime_gpu=false
if grep -Eiq \
  'ggml_vulkan: [0-9]+ = |Found [1-9][0-9]* Vulkan devices|using Vulkan[0-9]* backend|using CUDA[0-9]* backend|found [1-9][0-9]* CUDA devices|CUDA device [0-9]+|using Metal backend|Metal device[^:]*:' \
  "$output_base.whisper.log"; then
  runtime_gpu=true
fi
if [ "$runtime_gpu" = false ] && [ "$allow_cpu" -eq 0 ]; then
  fail "full transcription log lacks a positive GPU marker" 3
fi

duration="$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 "$input")"
jq -n \
  --arg input "$input" \
  --arg outputBase "$output_base" \
  --arg model "$model" \
  --arg duration "$duration" \
  --arg backend "$backend" \
  --arg device "$device" \
  --argjson tinydiarize "$([ "$tinydiarize" -eq 1 ] && echo true || echo false)" \
  --argjson cpuAuthorized "$([ "$allow_cpu" -eq 1 ] && echo true || echo false)" \
  '{
    input:$input,
    outputBase:$outputBase,
    model:$model,
    sourceDurationSeconds:($duration|tonumber),
    asr:{backend:$backend,device:$device,cpuAuthorized:$cpuAuthorized},
    tinydiarize:$tinydiarize,
    outputs:{
      text:($outputBase+".txt"),
      srt:($outputBase+".srt"),
      json:($outputBase+".json"),
      runtimeLog:($outputBase+".whisper.log")
    }
  }' >"$output_base.transcription.json"

cat "$output_base.transcription.json"
