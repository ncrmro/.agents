#!/usr/bin/env bash
# Read-only by default. Installation is explicit and delegated to the Nix-only
# helper; tool presence is not evidence that a GPU backend is active.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install=0
json=0

usage() {
  cat <<'EOF'
Usage: toolchain-doctor.sh [--install] [--json]

Check the transcription toolchain. --install explicitly adds missing packages
to a Nix profile. Homebrew and apt print suggested manual steps and make no
changes. This doctor cannot classify GPU execution without a model and audio;
transcribe-media.sh checks the runtime log before each job.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --install) install=1 ;;
    --json) json=1 ;;
    -q|--quiet) ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'deps-doctor: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

missing=()
command -v ffmpeg >/dev/null 2>&1 &&
  command -v ffprobe >/dev/null 2>&1 || missing+=(ffmpeg)
command -v jq >/dev/null 2>&1 || missing+=(jq)
command -v whisper-cli >/dev/null 2>&1 || missing+=(whisper)

model_dir=${WHISPER_MODEL_DIR:-"$HOME/.cache/whisper"}
model_found=false
if [ -n "${WHISPER_MODEL:-}" ] && [ -f "$WHISPER_MODEL" ]; then
  model_found=true
else
  for candidate in "$model_dir"/ggml-*.bin; do
    if [ -f "$candidate" ]; then
      model_found=true
      break
    fi
  done
fi

whisperx=false
command -v whisperx >/dev/null 2>&1 && whisperx=true
hf_token=false
[ -n "${HF_TOKEN:-${HUGGINGFACE_TOKEN:-}}" ] && hf_token=true

if [ "$json" -eq 1 ]; then
  jq -n \
    --argjson missing "$(printf '%s\n' "${missing[@]:-}" |
      jq -Rsc 'split("\n") | map(select(length > 0))')" \
    --argjson model "$model_found" \
    --argjson whisperx "$whisperx" \
    --argjson hfToken "$hf_token" \
    '{
      missingRequired:$missing,
      modelPresent:$model,
      diarization:{whisperxPresent:$whisperx,hfTokenPresent:$hfToken},
      gpu:"unverified; transcribe-media.sh performs a runtime probe"
    }'
else
  if [ "${#missing[@]}" -eq 0 ]; then
    printf 'required commands: present\n'
  else
    printf 'missing commands: %s\n' "${missing[*]}"
  fi
  if [ "$model_found" = true ]; then
    printf 'whisper model: present\n'
  else
    printf 'whisper model: missing; set --model, WHISPER_MODEL, or WHISPER_MODEL_DIR\n'
  fi
  printf 'GPU backend: unverified until transcribe-media.sh runs its probe\n'
  printf 'diarization: whisperx=%s HF_TOKEN=%s\n' "$whisperx" "$hf_token"
fi

if [ "${#missing[@]}" -gt 0 ]; then
  if [ "$install" -eq 1 ]; then
    "$script_dir/install-remediation.sh" --install "${missing[@]}"
  else
    "$script_dir/install-remediation.sh" "${missing[@]}" || true
  fi
fi

[ "${#missing[@]}" -eq 0 ] && [ "$model_found" = true ]
