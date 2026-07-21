#!/usr/bin/env bash
# deps-doctor.sh — check (and optionally install) the media transcription
# toolchain, printing exact, environment-appropriate install instructions.
#
# Capabilities checked: ffmpeg/ffprobe, whisper-cli (whisper.cpp), a whisper
# model, whisperx (diarization), docling (PDF), and an optional Ollama endpoint
# with a text LLM (default nemotron) used for transcript POST-PROCESSING —
# speaker naming, cleanup, summaries — NOT for speech-to-text.
#
# Default run only reports and prints remediation. With --install it installs
# missing pieces via the detected package manager (nix profile / brew / apt /
# uv / ollama). Idempotent: only missing items are touched.
#
# Exit status: 0 when every REQUIRED capability is present, 1 otherwise.
#
# Env overrides (nothing machine-specific is hardcoded):
#   OLLAMA_HOST        default http://localhost:11434
#   NEMOTRON_MODEL     default nemotron-3-nano
#   WHISPER_MODEL_DIR  default $HOME/.cache/whisper
#   HF_TOKEN / HUGGINGFACE_TOKEN   gated pyannote weights for whisperx --diarize

set -u

# --------------------------------------------------------------------------
# Config / args
# --------------------------------------------------------------------------
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
NEMOTRON_MODEL="${NEMOTRON_MODEL:-nemotron-3-nano}"
WHISPER_MODEL_DIR="${WHISPER_MODEL_DIR:-$HOME/.cache/whisper}"
HF_TOKEN="${HF_TOKEN:-${HUGGINGFACE_TOKEN:-}}"

DO_INSTALL=0
QUIET=0
JSON=0

usage() {
  cat <<'EOF'
Usage: deps-doctor.sh [--install] [--json] [-q|--quiet] [-h|--help]

  --install   Install missing dependencies with the detected package manager.
  --json      Emit machine-readable JSON instead of the human report.
  -q, --quiet Only print MISSING lines and the summary.
  -h, --help  Show this help.

Env: OLLAMA_HOST, NEMOTRON_MODEL, WHISPER_MODEL_DIR, HF_TOKEN/HUGGINGFACE_TOKEN.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --install) DO_INSTALL=1 ;;
    --json)    JSON=1 ;;
    -q|--quiet) QUIET=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

# --------------------------------------------------------------------------
# Colors (respect NO_COLOR and non-TTY)
# --------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "$JSON" -eq 0 ]; then
  C_OK=$'\033[32m'; C_MISS=$'\033[31m'; C_WARN=$'\033[33m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_OK=""; C_MISS=""; C_WARN=""; C_DIM=""; C_RST=""
fi

have() { command -v "$1" >/dev/null 2>&1; }

# --------------------------------------------------------------------------
# Environment detection
# --------------------------------------------------------------------------
UNAME="$(uname -s 2>/dev/null || echo unknown)"
IS_NIXOS=0
if [ -r /etc/os-release ] && grep -q '^ID=nixos' /etc/os-release 2>/dev/null; then IS_NIXOS=1; fi
HAS_NIX=0;    have nix     && HAS_NIX=1
HAS_DEVENV=0; have devenv  && HAS_DEVENV=1
HAS_BREW=0;   have brew    && HAS_BREW=1
HAS_APT=0;    have apt-get && HAS_APT=1
HAS_UV=0;     have uv      && HAS_UV=1
HAS_OLLAMA=0; have ollama  && HAS_OLLAMA=1
HAS_CURL=0;   have curl    && HAS_CURL=1

# Pick the primary package-manager style for remediation strings.
#   nix  -> nix profile
#   brew -> Homebrew (macOS)
#   apt  -> Debian/Ubuntu
#   none -> report only
PM="none"
if [ "$HAS_NIX" -eq 1 ]; then PM="nix"
elif [ "$HAS_BREW" -eq 1 ]; then PM="brew"
elif [ "$HAS_APT" -eq 1 ]; then PM="apt"
fi

# --------------------------------------------------------------------------
# Result accumulation
# --------------------------------------------------------------------------
MISSING_REQUIRED=0
JSON_ITEMS=""

# record NAME STATUS(ok|missing|warn) REQUIRED(0|1) DETAIL REMEDIATION
record() {
  local name="$1" status="$2" required="$3" detail="$4" remediation="$5"
  if [ "$JSON" -eq 1 ]; then
    local esc_detail esc_rem
    esc_detail=$(printf '%s' "$detail" | sed 's/\\/\\\\/g; s/"/\\"/g')
    esc_rem=$(printf '%s' "$remediation" | sed 's/\\/\\\\/g; s/"/\\"/g')
    JSON_ITEMS="${JSON_ITEMS:+$JSON_ITEMS,}"$'\n'"  {\"name\":\"$name\",\"status\":\"$status\",\"required\":$([ "$required" -eq 1 ] && echo true || echo false),\"detail\":\"$esc_detail\",\"remediation\":\"$esc_rem\"}"
    return
  fi
  local tag
  case "$status" in
    ok)      tag="${C_OK}[  ok   ]${C_RST}" ;;
    warn)    tag="${C_WARN}[ warn  ]${C_RST}" ;;
    missing) tag="${C_MISS}[MISSING]${C_RST}" ;;
  esac
  if [ "$QUIET" -eq 1 ] && [ "$status" = ok ]; then return; fi
  printf '%s %-16s %s\n' "$tag" "$name" "$detail"
  if [ "$status" != ok ] && [ -n "$remediation" ]; then
    printf '           %s→ %s%s\n' "$C_DIM" "$remediation" "$C_RST"
  fi
}

# Build a nix-profile remediation for a package attr (falls back per PM).
nix_add() { printf 'nix profile add nixpkgs#%s' "$1"; }

# --------------------------------------------------------------------------
# Install helpers
# --------------------------------------------------------------------------
run() { echo "  ${C_DIM}\$ $*${C_RST}"; "$@"; }

install_nix() { # $1 = attr
  [ "$HAS_NIX" -eq 1 ] || { echo "  nix not available; cannot auto-install $1" >&2; return 1; }
  run env NIXPKGS_ALLOW_UNFREE=1 nix profile add "nixpkgs#$1" --impure
}

# --------------------------------------------------------------------------
# Checks
# --------------------------------------------------------------------------
check_ffmpeg() {
  local attr="ffmpeg"
  local rem
  case "$PM" in
    nix)  rem="$(nix_add ffmpeg)" ;;
    brew) rem="brew install ffmpeg" ;;
    apt)  rem="sudo apt-get install -y ffmpeg" ;;
    *)    rem="install ffmpeg via your OS package manager" ;;
  esac
  if have ffmpeg && have ffprobe; then
    record "ffmpeg" ok 1 "$(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f1-3)" ""
  else
    record "ffmpeg" missing 1 "ffmpeg/ffprobe not on PATH" "$rem"
    MISSING_REQUIRED=1
    [ "$DO_INSTALL" -eq 1 ] && { [ "$PM" = nix ] && install_nix "$attr"; }
  fi
}

check_whisper_cli() {
  # Prefer the GPU (Vulkan) build on Nix; note the driver requirement.
  local rem
  case "$PM" in
    nix)  rem="$(nix_add whisper-cpp-vulkan)  # GPU (needs Vulkan drivers); or nixpkgs#whisper-cpp for CPU" ;;
    brew) rem="brew install whisper-cpp       # Metal-accelerated on Apple Silicon" ;;
    apt)  rem="build whisper.cpp from source (see setup-tools.md) — not packaged in apt" ;;
    *)    rem="install whisper.cpp (provides whisper-cli)" ;;
  esac
  if have whisper-cli; then
    record "whisper-cli" ok 1 "present" ""
  else
    record "whisper-cli" missing 1 "whisper.cpp not on PATH" "$rem"
    MISSING_REQUIRED=1
    [ "$DO_INSTALL" -eq 1 ] && [ "$PM" = nix ] && install_nix "whisper-cpp-vulkan"
  fi
}

check_whisper_model() {
  local rem="mkdir -p '$WHISPER_MODEL_DIR' && curl -L -o '$WHISPER_MODEL_DIR/ggml-small.en-tdrz.bin' https://huggingface.co/akashmjn/tinydiarize-whisper.cpp/resolve/main/ggml-small.en-tdrz.bin"
  if ls "$WHISPER_MODEL_DIR"/ggml-*.bin >/dev/null 2>&1; then
    local models; models="$(cd "$WHISPER_MODEL_DIR" && ls ggml-*.bin 2>/dev/null | tr '\n' ' ')"
    record "whisper-model" ok 1 "$models" ""
  else
    record "whisper-model" missing 1 "no ggml-*.bin in $WHISPER_MODEL_DIR" "$rem"
    MISSING_REQUIRED=1
    if [ "$DO_INSTALL" -eq 1 ] && [ "$HAS_CURL" -eq 1 ]; then
      mkdir -p "$WHISPER_MODEL_DIR"
      run curl -L -o "$WHISPER_MODEL_DIR/ggml-small.en-tdrz.bin" \
        "https://huggingface.co/akashmjn/tinydiarize-whisper.cpp/resolve/main/ggml-small.en-tdrz.bin"
      # large-v3 (~3 GB) is gated behind an explicit prompt.
      if [ -t 0 ]; then
        printf '  Also download ggml-large-v3.bin (~3 GB, best accuracy)? [y/N] '
        read -r ans
        case "$ans" in
          y|Y) run curl -L -o "$WHISPER_MODEL_DIR/ggml-large-v3.bin" \
                 "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin" ;;
        esac
      fi
    fi
  fi
}

check_whisperx() {
  local rem
  case "$PM" in
    nix)  rem="$(nix_add whisperx)  # diarization: faster-whisper + pyannote" ;;
    *)    rem="uv tool install whisperx   # or: pipx install whisperx" ;;
  esac
  if have whisperx || python3 -c 'import whisperx' >/dev/null 2>&1; then
    record "whisperx" ok 1 "present (multi-speaker diarization)" ""
  else
    record "whisperx" missing 1 "not installed (needed for >2-speaker diarization)" "$rem"
    MISSING_REQUIRED=1
    if [ "$DO_INSTALL" -eq 1 ]; then
      if [ "$PM" = nix ]; then install_nix "whisperx"
      elif [ "$HAS_UV" -eq 1 ]; then run uv tool install whisperx; fi
    fi
  fi
}

check_hf_token() {
  local rem="get a token at https://hf.co/settings/tokens and accept the pyannote model terms at https://hf.co/pyannote/speaker-diarization-3.1 ; then export HF_TOKEN=…"
  if [ -n "$HF_TOKEN" ]; then
    record "hf-token" ok 0 "set (pyannote diarization enabled)" ""
  else
    # Not fatal: whisperx still transcribes; diarization needs the token.
    record "hf-token" warn 0 "unset — whisperx --diarize will fail without it" "$rem"
  fi
}

check_docling() {
  local rem="uv tool install docling   # nixpkgs#docling is currently broken"
  if have docling; then
    record "docling" ok 0 "present (PDF → markdown)" ""
  else
    record "docling" warn 0 "optional (PDF ingest) not installed" "$rem"
    [ "$DO_INSTALL" -eq 1 ] && [ "$HAS_UV" -eq 1 ] && run uv tool install docling
  fi
}

check_ollama() {
  local rem_up="start Ollama (ollama serve) or set OLLAMA_HOST to a reachable endpoint"
  if [ "$HAS_CURL" -eq 0 ]; then
    record "ollama" warn 0 "curl missing; cannot probe $OLLAMA_HOST" "install curl"
    return
  fi
  local ver
  if ver="$(curl -fs --max-time 4 "$OLLAMA_HOST/api/version" 2>/dev/null)"; then
    record "ollama" ok 0 "reachable at $OLLAMA_HOST ($ver)" ""
    # Nemotron (or configured) model present? — LLM transcript post-processing.
    local tags
    tags="$(curl -fs --max-time 6 "$OLLAMA_HOST/api/tags" 2>/dev/null || true)"
    if printf '%s' "$tags" | grep -q "\"name\":\"${NEMOTRON_MODEL}"; then
      record "nemotron" ok 0 "$NEMOTRON_MODEL available (transcript post-processing)" ""
    else
      record "nemotron" warn 0 "$NEMOTRON_MODEL not pulled on $OLLAMA_HOST" "ollama pull $NEMOTRON_MODEL"
      if [ "$DO_INSTALL" -eq 1 ] && [ "$HAS_OLLAMA" -eq 1 ]; then run ollama pull "$NEMOTRON_MODEL"; fi
    fi
  else
    record "ollama" warn 0 "endpoint $OLLAMA_HOST not reachable (optional)" "$rem_up"
  fi
}

# --------------------------------------------------------------------------
# Run
# --------------------------------------------------------------------------
if [ "$JSON" -eq 0 ]; then
  printf '%stranscription toolchain — deps-doctor%s\n' "$C_DIM" "$C_RST"
  printf '%sos=%s nixos=%s pkg-manager=%s devenv=%s install=%s%s\n\n' \
    "$C_DIM" "$UNAME" "$IS_NIXOS" "$PM" "$HAS_DEVENV" "$DO_INSTALL" "$C_RST"
fi

check_ffmpeg
check_whisper_cli
check_whisper_model
check_whisperx
check_hf_token
check_docling
check_ollama

if [ "$JSON" -eq 1 ]; then
  printf '{"missing_required":%s,"items":[%s\n]}\n' \
    "$([ "$MISSING_REQUIRED" -eq 1 ] && echo true || echo false)" "$JSON_ITEMS"
else
  echo
  if [ "$MISSING_REQUIRED" -eq 0 ]; then
    printf '%s✓ all required transcription tools are present%s\n' "$C_OK" "$C_RST"
  else
    printf '%s✗ required tools missing%s' "$C_MISS" "$C_RST"
    [ "$DO_INSTALL" -eq 0 ] && printf ' — re-run with %s--install%s to fix, or copy the commands above' "$C_WARN" "$C_RST"
    echo
  fi
fi

[ "$MISSING_REQUIRED" -eq 0 ]
