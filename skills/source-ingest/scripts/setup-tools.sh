#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
profile="${SOURCE_INGEST_NIX_PROFILE:-$HOME/.nix-profile}"
model_dir="${WHISPER_MODEL_DIR:-$HOME/.cache/whisper}"
large_model=0
with_whisperx=0

usage() {
  cat <<'EOF'
Usage: setup-tools.sh [--large-model] [--with-whisperx]

Install source-ingest tools into the user Nix profile. The default setup
installs the Vulkan whisper.cpp build and the English tinydiarize model.

  --large-model     Also download ggml-large-v3.bin (~3 GB).
  --with-whisperx   Also install WhisperX (HF token/terms still required).
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --large-model) large_model=1 ;;
    --with-whisperx) with_whisperx=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'setup-tools: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

if ! command -v nix >/dev/null 2>&1; then
  printf '%s\n' \
    'setup-tools: automatic installation requires Nix.' \
    'Install ffmpeg, jq, uv, a GPU-enabled whisper.cpp, and Docling manually.' >&2
  exit 2
fi

printf 'Installing core tools into %s\n' "$profile"
nix profile add --profile "$profile" \
  nixpkgs#ffmpeg nixpkgs#jq nixpkgs#uv nixpkgs#curl \
  nixpkgs#libxcb nixpkgs#libglvnd nixpkgs#glib.out nixpkgs#zlib \
  nixpkgs#gcc.cc.lib
nix profile add --profile "$profile" --priority 4 \
  nixpkgs#whisper-cpp-vulkan

if [ "$with_whisperx" -eq 1 ]; then
  nix profile add --profile "$profile" nixpkgs#whisperx
fi

export PATH="$profile/bin:$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$profile/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

command -v uv >/dev/null 2>&1 ||
  { printf 'setup-tools: uv is unavailable after profile install\n' >&2; exit 1; }
command -v docling >/dev/null 2>&1 || uv tool install docling

download_model() {
  local name=$1 url=$2 destination partial
  destination="$model_dir/$name"
  [ -s "$destination" ] && return
  mkdir -p "$model_dir"
  partial="$destination.partial"
  rm -f -- "$partial"
  printf 'Downloading %s\n' "$name"
  curl --fail --location --retry 3 --output "$partial" "$url"
  mv -- "$partial" "$destination"
}

download_model ggml-small.en-tdrz.bin \
  'https://huggingface.co/akashmjn/tinydiarize-whisper.cpp/resolve/main/ggml-small.en-tdrz.bin'

if [ "$large_model" -eq 1 ]; then
  download_model ggml-large-v3.bin \
    'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin'
fi

"$script_dir/toolchain-doctor.sh"
