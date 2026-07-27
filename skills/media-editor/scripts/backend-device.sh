#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  backend-device.sh whisper MODEL PROBE.wav LOG OUTPUT_BASE
  backend-device.sh whisperx

The whisper probe actually loads the model and classifies its runtime log.
No GPU is reported without a positive Vulkan, Metal, or CUDA runtime marker.
The whisperx probe reports CUDA only when its active Python torch runtime can
allocate CUDA; other platforms are CPU for CTranslate2 compatibility.
Output is JSON.
EOF
}

fail() {
  printf 'backend-device: %s\n' "$*" >&2
  exit 2
}

json_result() {
  jq -n \
    --arg backend "$1" \
    --arg device "$2" \
    --arg reason "$3" \
    '{backend:$backend,device:$device,reason:$reason}'
}

probe_whisper() {
  [ "$#" -eq 4 ] || fail "whisper requires MODEL PROBE.wav LOG OUTPUT_BASE"
  model=$1
  audio=$2
  log=$3
  output_base=$4
  command -v whisper-cli >/dev/null 2>&1 ||
    fail "whisper-cli is not available on PATH"
  command -v jq >/dev/null 2>&1 || fail "jq is not available on PATH"

  if ! whisper-cli -m "$model" -f "$audio" --output-json \
    --output-file "$output_base" >"$log" 2>&1; then
    printf 'backend-device: whisper runtime probe failed; see %s\n' "$log" >&2
    exit 1
  fi

  if grep -Eiq 'using Vulkan[0-9]* backend|loaded Vulkan backend|ggml_vulkan' "$log"; then
    device=$(sed -nE 's/.*using (Vulkan[0-9]+) backend.*/\1/ip' "$log" | head -n 1)
    json_result vulkan "${device:-Vulkan GPU}" \
      "verified from whisper-cli runtime log"
  elif grep -Eiq 'using CUDA[0-9]* backend|loaded CUDA backend|ggml_cuda' "$log"; then
    device=$(sed -nE 's/.*using (CUDA[0-9]+) backend.*/\1/ip' "$log" | head -n 1)
    json_result cuda "${device:-CUDA GPU}" \
      "verified from whisper-cli runtime log"
  elif grep -Eiq 'using Metal backend|ggml_metal|Metal device' "$log"; then
    device=$(sed -nE 's/.*Metal device[^:]*:[[:space:]]*(.*)/\1/ip' "$log" | head -n 1)
    json_result metal "${device:-Metal GPU}" \
      "verified from whisper-cli runtime log"
  elif grep -Eiq 'loaded CPU backend|using CPU backend|ggml_cpu' "$log"; then
    json_result cpu CPU "whisper-cli runtime loaded only the CPU backend"
  else
    json_result cpu CPU \
      "no positive GPU backend marker appeared in the whisper-cli runtime log"
  fi
}

probe_whisperx() {
  command -v jq >/dev/null 2>&1 || fail "jq is not available on PATH"
  if ! command -v whisperx >/dev/null 2>&1; then
    json_result unavailable unavailable "whisperx is not available on PATH"
    return
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    json_result cpu CPU "python3 is unavailable, so CUDA could not be verified"
    return
  fi

  probe=$(python3 -c '
try:
    import torch
    if torch.cuda.is_available():
        torch.zeros(1, device="cuda")
        print("cuda\t" + torch.cuda.get_device_name(0))
    else:
        print("cpu\tCPU")
except Exception:
    print("cpu\tCPU")
' 2>/dev/null || printf 'cpu\tCPU')
  backend=${probe%%	*}
  device=${probe#*	}
  if [ "$backend" = cuda ]; then
    json_result cuda "$device" \
      "verified by an allocation in whisperx's torch runtime"
  else
    json_result cpu CPU \
      "whisperx/CTranslate2 has no verified CUDA runtime; using CPU"
  fi
}

case "${1:-}" in
  whisper) shift; probe_whisper "$@" ;;
  whisperx)
    shift
    [ "$#" -eq 0 ] || fail "whisperx takes no arguments"
    probe_whisperx
    ;;
  -h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
