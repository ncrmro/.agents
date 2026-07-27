#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$script_dir/../.env"
if [ -f "$env_file" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$env_file"
  set +a
fi

usage() {
  cat <<'EOF'
Usage: transcribe-media.sh FILE [options]

Write raw, timestamped whisper.cpp transcripts next to FILE by default. The
command reports GPU use only when a runtime marker identifies Vulkan, Metal, or
CUDA. Auto diarization runs only when stream metadata indicates multiple
speakers and its prerequisites are available.

Options:
  --output-base PATH       Artifact path without an extension (default: FILE stem)
  --model FILE             Local whisper.cpp ggml model
  --audio-stream INDEX     Absolute ffmpeg audio stream index (default: first)
  --diarize POLICY         auto, always, or never (default: auto)
  --require-gpu            Refuse any required stage that would run on CPU
  --install                Explicitly install missing tools on Nix only
  --json                   Print only final metadata JSON to stdout
  -h, --help               Show this help

Artifacts:
  BASE.txt, BASE.srt, BASE.json       raw whisper.cpp outputs
  BASE.whisper.log                   runtime backend evidence
  BASE.diarized.*                    raw WhisperX outputs when selected
  BASE.whisperx.log                  WhisperX runtime log when selected
  BASE.transcription.json            backend/device/decision metadata

Existing artifacts are never overwritten. Models are never downloaded.
Automatic installation is supported only on Nix. On Homebrew or apt, the
command prints suggested manual steps and exits without making changes.
EOF
}

fail() {
  printf 'transcribe-media: %s\n' "$1" >&2
  exit "${2:-1}"
}

say() {
  [ "$json_only" -eq 1 ] || printf '%s\n' "$*" >&2
}

absolute_existing() {
  path=$1
  directory=$(dirname "$path")
  basename=$(basename "$path")
  (cd "$directory" && printf '%s/%s\n' "$PWD" "$basename")
}

absolute_output_base() {
  path=$1
  directory=$(dirname "$path")
  basename=$(basename "$path")
  mkdir -p "$directory"
  (cd "$directory" && printf '%s/%s\n' "$PWD" "$basename")
}

choose_model() {
  if [ -n "$model" ]; then
    printf '%s\n' "$model"
    return
  fi
  if [ -n "${WHISPER_MODEL:-}" ]; then
    printf '%s\n' "$WHISPER_MODEL"
    return
  fi
  model_dir=${WHISPER_MODEL_DIR:-"$HOME/.cache/whisper"}
  for name in \
    ggml-large-v3.bin ggml-small.en.bin ggml-small.en-tdrz.bin ggml-base.en.bin
  do
    if [ -f "$model_dir/$name" ]; then
      printf '%s\n' "$model_dir/$name"
      return
    fi
  done
  return 1
}

ensure_core_tools() {
  missing=()
  command -v ffmpeg >/dev/null 2>&1 &&
    command -v ffprobe >/dev/null 2>&1 || missing+=(ffmpeg)
  command -v jq >/dev/null 2>&1 || missing+=(jq)
  command -v whisper-cli >/dev/null 2>&1 || missing+=(whisper)
  [ "${#missing[@]}" -eq 0 ] && return

  if [ "$install" -eq 1 ]; then
    "$script_dir/install-remediation.sh" --install "${missing[@]}" >&2 ||
      fail "dependency installation did not complete" 2
  else
    "$script_dir/install-remediation.sh" "${missing[@]}" >&2 || true
    fail "required tools are missing; review remediation or use --install on Nix" 2
  fi
}

refuse_collisions() {
  collisions=()
  for artifact in "$@"; do
    [ ! -e "$artifact" ] || collisions+=("$artifact")
  done
  [ "${#collisions[@]}" -eq 0 ] ||
    fail "refusing to overwrite: ${collisions[*]}; choose --output-base" 2
}

input=
output_base=
model=
audio_stream=
diarize=auto
require_gpu=0
install=0
json_only=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-base|--model|--audio-stream|--diarize)
      [ "$#" -ge 2 ] || fail "$1 requires a value" 2
      case "$1" in
        --output-base) output_base=$2 ;;
        --model) model=$2 ;;
        --audio-stream) audio_stream=$2 ;;
        --diarize) diarize=$2 ;;
      esac
      shift 2
      ;;
    --require-gpu) require_gpu=1; shift ;;
    --install) install=1; shift ;;
    --json) json_only=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) fail "unknown option: $1" 2 ;;
    *)
      [ -z "$input" ] || fail "exactly one media FILE is required" 2
      input=$1
      shift
      ;;
  esac
done

[ -n "$input" ] || { usage >&2; exit 2; }
[ -f "$input" ] || fail "file does not exist: $input" 2
case "$diarize" in
  auto|always|never) ;;
  *) fail "--diarize must be auto, always, or never" 2 ;;
esac
if [ -n "$audio_stream" ]; then
  case "$audio_stream" in
    *[!0-9]*) fail "--audio-stream must be an integer" 2 ;;
  esac
fi

ensure_core_tools
input=$(absolute_existing "$input")
if [ -z "$output_base" ]; then
  case "${input##*/}" in
    *.*) output_base=${input%.*} ;;
    *) output_base=$input ;;
  esac
else
  output_base=$(absolute_output_base "$output_base")
fi

model=$(choose_model) ||
  fail "no model found; use --model, WHISPER_MODEL, or WHISPER_MODEL_DIR" 2
[ -f "$model" ] || fail "model does not exist: $model" 2
model=$(absolute_existing "$model")

raw_txt="$output_base.txt"
raw_srt="$output_base.srt"
raw_json="$output_base.json"
whisper_log="$output_base.whisper.log"
metadata="$output_base.transcription.json"
refuse_collisions "$raw_txt" "$raw_srt" "$raw_json" "$whisper_log" "$metadata"

probe_json=$(ffprobe -v error -show_streams -of json "$input")
if [ -z "$audio_stream" ]; then
  audio_stream=$(printf '%s' "$probe_json" |
    jq -r '[.streams[] | select(.codec_type=="audio")][0].index // empty')
else
  found=$(printf '%s' "$probe_json" |
    jq -r --argjson index "$audio_stream" \
      '[.streams[] | select(.codec_type=="audio" and .index==$index)] | length')
  [ "$found" -eq 1 ] || fail "audio stream $audio_stream was not found" 2
fi
[ -n "$audio_stream" ] || fail "media has no audio stream" 2
stream_title=$(printf '%s' "$probe_json" |
  jq -r --argjson index "$audio_stream" \
    '.streams[] | select(.index==$index) | (.tags.title // "")')

diarization_selected=false
diarization_reason=
case "$diarize" in
  always)
    diarization_selected=true
    diarization_reason="required by --diarize always"
    ;;
  never)
    diarization_reason="disabled by --diarize never"
    ;;
  auto)
    if printf '%s' "$stream_title" |
      grep -Eiq 'meeting|conference|interview|panel|guest|mixed[ _-]?speaker'
    then
      if command -v whisperx >/dev/null 2>&1 &&
        [ -n "${HF_TOKEN:-${HUGGINGFACE_TOKEN:-}}" ]
      then
        diarization_selected=true
        diarization_reason="stream title '$stream_title' signals multiple speakers and WhisperX prerequisites are present"
      else
        diarization_reason="stream title '$stream_title' suggests multiple speakers, but WhisperX or HF_TOKEN is unavailable; use --diarize always after setup"
      fi
    else
      diarization_reason="no reliable multi-speaker signal in stream metadata; speaker count is not inferred from channels or audio; use --diarize always when labels are needed"
    fi
    ;;
esac

whisperx_backend_json=$(jq -n \
  '{backend:"not-run",device:"not-run",reason:"diarization not selected"}')
if [ "$diarization_selected" = true ]; then
  if ! command -v whisperx >/dev/null 2>&1 && [ "$install" -eq 1 ]; then
    "$script_dir/install-remediation.sh" --install whisperx >&2 ||
      fail "WhisperX installation did not complete" 2
  fi
  command -v whisperx >/dev/null 2>&1 ||
    fail "diarization is required but whisperx is unavailable" 2
  [ -n "${HF_TOKEN:-${HUGGINGFACE_TOKEN:-}}" ] ||
    fail "diarization is required but HF_TOKEN/HUGGINGFACE_TOKEN is unset" 2
  refuse_collisions \
    "$output_base.diarized.txt" "$output_base.diarized.srt" \
    "$output_base.diarized.vtt" "$output_base.diarized.tsv" \
    "$output_base.diarized.json" "$output_base.whisperx.log"
  whisperx_backend_json=$("$script_dir/backend-device.sh" whisperx)
  whisperx_backend=$(printf '%s' "$whisperx_backend_json" | jq -r .backend)
  whisperx_reason=$(printf '%s' "$whisperx_backend_json" | jq -r .reason)
  if [ "$whisperx_backend" = cpu ]; then
    say "WhisperX backend: CPU fallback ($whisperx_reason)"
    [ "$require_gpu" -eq 0 ] ||
      fail "--require-gpu refused CPU WhisperX diarization: $whisperx_reason" 3
  else
    say "WhisperX backend: $whisperx_backend ($(printf '%s' \
      "$whisperx_backend_json" | jq -r .device))"
  fi
fi
say "Diarization: $diarization_selected ($diarization_reason)"

scratch=$(mktemp -d)
cleanup() {
  [ -n "${scratch:-}" ] && [ -d "$scratch" ] && rm -rf -- "$scratch"
}
trap cleanup EXIT
wav="$scratch/audio.wav"
probe_wav="$scratch/probe.wav"
"$script_dir/extract-audio.sh" "$input" "$wav" \
  --audio-stream "$audio_stream"
"$script_dir/extract-audio.sh" "$input" "$probe_wav" \
  --audio-stream "$audio_stream" --duration 0.25

backend_json=$("$script_dir/backend-device.sh" whisper \
  "$model" "$probe_wav" "$whisper_log" "$scratch/probe")
backend=$(printf '%s' "$backend_json" | jq -r .backend)
device=$(printf '%s' "$backend_json" | jq -r .device)
backend_reason=$(printf '%s' "$backend_json" | jq -r .reason)
if [ "$backend" = cpu ]; then
  say "ASR backend: CPU fallback ($backend_reason)"
  [ "$require_gpu" -eq 0 ] ||
    fail "--require-gpu refused CPU transcription: $backend_reason" 3
else
  say "ASR backend: $backend ($device), verified at runtime"
fi

whisper-cli -m "$model" -f "$wav" --output-txt --output-srt --output-json \
  --output-file "$output_base" >>"$whisper_log" 2>&1 ||
  fail "whisper-cli failed; see $whisper_log"
for artifact in "$raw_txt" "$raw_srt" "$raw_json"; do
  [ -s "$artifact" ] || fail "expected raw transcript is missing: $artifact"
done

if [ "$diarization_selected" = true ]; then
  whisperx_dir="$scratch/whisperx"
  mkdir "$whisperx_dir"
  whisperx_backend=$(printf '%s' "$whisperx_backend_json" | jq -r .backend)
  whisperx_model=${WHISPERX_MODEL:-large-v3}
  compute_type=int8
  [ "$whisperx_backend" != cuda ] || compute_type=float16
  whisperx "$wav" --model "$whisperx_model" \
    --device "$whisperx_backend" --compute_type "$compute_type" \
    --diarize --hf_token "${HF_TOKEN:-${HUGGINGFACE_TOKEN:-}}" \
    --output_format all --output_dir "$whisperx_dir" \
    >"$output_base.whisperx.log" 2>&1 ||
    fail "WhisperX diarization failed; see $output_base.whisperx.log"
  copied=0
  for extension in txt srt vtt tsv json; do
    source_file="$whisperx_dir/audio.$extension"
    if [ -s "$source_file" ]; then
      cp -- "$source_file" "$output_base.diarized.$extension"
      copied=1
    fi
  done
  [ "$copied" -eq 1 ] ||
    fail "WhisperX completed without recognized transcript artifacts"
fi

jq -n \
  --arg file "$input" \
  --arg outputBase "$output_base" \
  --arg model "$model" \
  --argjson audioStream "$audio_stream" \
  --arg policy "$diarize" \
  --argjson selected "$diarization_selected" \
  --arg decision "$diarization_reason" \
  --argjson asr "$backend_json" \
  --argjson whisperx "$whisperx_backend_json" \
  --arg txt "$raw_txt" \
  --arg srt "$raw_srt" \
  --arg json "$raw_json" \
  --arg log "$whisper_log" \
  '{
    file:$file,
    outputBase:$outputBase,
    model:$model,
    audioStreamIndex:$audioStream,
    asr:$asr,
    diarization:{
      policy:$policy,
      selected:$selected,
      decision:$decision,
      runtime:$whisperx
    },
    outputs:{text:$txt,srt:$srt,json:$json,whisperLog:$log}
  }' >"$metadata"

if [ "$json_only" -eq 1 ]; then
  cat "$metadata"
else
  say "Transcript metadata: $metadata"
  cat "$metadata"
fi
