#!/usr/bin/env bash
set -euo pipefail

profile="${SOURCE_INGEST_NIX_PROFILE:-$HOME/.nix-profile}"
model_dir="${WHISPER_MODEL_DIR:-$HOME/.cache/whisper}"
allow_cpu=0
json=0

usage() {
  cat <<'EOF'
Usage: toolchain-doctor.sh [--json] [--allow-cpu]

Verify the source-ingest toolchain and positively classify Whisper's runtime
backend. CPU-only execution fails unless --allow-cpu is explicit.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --json) json=1 ;;
    --allow-cpu) allow_cpu=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'toolchain-doctor: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

export PATH="$profile/bin:$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$profile/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

missing=()
for command_name in ffmpeg ffprobe jq whisper-cli docling; do
  command -v "$command_name" >/dev/null 2>&1 || missing+=("$command_name")
done

model_present=false
for candidate in "$model_dir"/ggml-*.bin; do
  if [ -s "$candidate" ]; then model_present=true; break; fi
done

runtime_log=
backend=unavailable
device=unavailable
reason='whisper-cli is unavailable'
resolved_whisper=

if command -v whisper-cli >/dev/null 2>&1; then
  resolved_whisper="$(readlink -f "$(command -v whisper-cli)")"
  runtime_log="$(whisper-cli --version 2>&1 || true)"
  if grep -Eiq \
    'ggml_vulkan: [0-9]+ = |Found [1-9][0-9]* Vulkan devices|using Vulkan[0-9]* backend' \
    <<<"$runtime_log"; then
    backend=vulkan
    device="$(sed -nE 's/.*ggml_vulkan: [0-9]+ = ([^(|]+).*/\1/p' \
      <<<"$runtime_log" | head -n 1 | sed 's/[[:space:]]*$//')"
    [ -n "$device" ] || device='Vulkan GPU'
    reason='verified from whisper-cli runtime markers'
  elif grep -Eiq \
    'using CUDA[0-9]* backend|found [1-9][0-9]* CUDA devices|CUDA device [0-9]+' \
    <<<"$runtime_log"; then
    backend=cuda
    device='CUDA GPU'
    reason='verified from whisper-cli runtime markers'
  elif grep -Eiq 'using Metal backend|Metal device[^:]*:' \
    <<<"$runtime_log"; then
    backend=metal
    device='Metal GPU'
    reason='verified from whisper-cli runtime markers'
  elif grep -Eiq 'loaded CPU backend|using CPU backend|ggml_cpu' \
    <<<"$runtime_log"; then
    backend=cpu
    device=CPU
    reason='whisper-cli loaded only the CPU backend'
  else
    backend=cpu
    device=CPU
    reason='no positive GPU runtime marker was observed'
  fi
fi

render_device=false
for candidate in /dev/dri/renderD*; do
  if [ -e "$candidate" ]; then render_device=true; break; fi
done

healthy=true
[ "${#missing[@]}" -eq 0 ] || healthy=false
[ "$model_present" = true ] || healthy=false
if [ "$backend" = cpu ] || [ "$backend" = unavailable ]; then
  [ "$allow_cpu" -eq 1 ] || healthy=false
fi

if [ "$json" -eq 1 ]; then
  command -v jq >/dev/null 2>&1 ||
    { printf 'toolchain-doctor: --json requires jq\n' >&2; exit 2; }
  jq -n \
    --argjson missing "$(printf '%s\n' "${missing[@]:-}" |
      jq -Rsc 'split("\n") | map(select(length > 0))')" \
    --argjson modelPresent "$model_present" \
    --arg backend "$backend" \
    --arg device "$device" \
    --arg reason "$reason" \
    --arg binary "$resolved_whisper" \
    --argjson renderDeviceVisible "$render_device" \
    --argjson healthy "$healthy" \
    '{
      healthy:$healthy,
      missing:$missing,
      modelPresent:$modelPresent,
      whisper:{backend:$backend,device:$device,reason:$reason,binary:$binary},
      renderDeviceVisible:$renderDeviceVisible
    }'
else
  if [ "${#missing[@]}" -eq 0 ]; then
    printf 'required commands: present\n'
  else
    printf 'missing commands: %s\n' "${missing[*]}"
  fi
  printf 'whisper model: %s\n' "$model_present"
  printf 'whisper binary: %s\n' "${resolved_whisper:-unavailable}"
  printf 'GPU render device visible: %s\n' "$render_device"
  printf 'ASR backend: %s (%s)\n' "$backend" "$device"
  printf 'backend evidence: %s\n' "$reason"
  if [ "$render_device" = false ] && [ "$backend" = cpu ]; then
    printf '%s\n' \
      'GPU device is hidden or unavailable; rerun with approved host-device access.' >&2
  fi
fi

[ "$healthy" = true ]
