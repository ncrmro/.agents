#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-remediation.sh [--install] PACKAGE...

Packages: ffmpeg jq whisper whisperx shellcheck

Without --install, print environment-specific remediation and make no changes.
With --install, Nix uses `nix profile add`. Existing/conflicting packages are
never removed. Homebrew and apt print suggested manual steps and exit without
making changes.

TRANSCRIBE_PACKAGE_MANAGER=nix|brew|apt|none overrides detection for tests.
EOF
}

fail() {
  printf 'install-remediation: %s\n' "$*" >&2
  exit 2
}

install=0
if [ "${1:-}" = "--install" ]; then
  install=1
  shift
fi
case "${1:-}" in -h|--help) usage; exit 0 ;; esac
[ "$#" -gt 0 ] || fail "at least one package is required"

if [ -n "${TRANSCRIBE_PACKAGE_MANAGER:-}" ]; then
  package_manager=$TRANSCRIBE_PACKAGE_MANAGER
elif command -v nix >/dev/null 2>&1; then
  package_manager=nix
elif command -v brew >/dev/null 2>&1; then
  package_manager=brew
elif command -v apt-get >/dev/null 2>&1; then
  package_manager=apt
else
  package_manager=none
fi

nix_attrs=()
for package in "$@"; do
  case "$package" in
    ffmpeg) nix_attrs+=(ffmpeg) ;;
    jq) nix_attrs+=(jq) ;;
    whisper)
      if [ "$(uname -s)" = Darwin ]; then
        nix_attrs+=(whisper-cpp)
      else
        nix_attrs+=(whisper-cpp-vulkan)
      fi
      ;;
    whisperx) nix_attrs+=(whisperx) ;;
    shellcheck) nix_attrs+=(shellcheck) ;;
    *) fail "unknown package: $package" ;;
  esac
done

case "$package_manager" in
  nix)
    printf 'Nix remediation: nix profile add'
    for attr in "${nix_attrs[@]}"; do printf ' nixpkgs#%s' "$attr"; done
    printf '\n'
    [ "$install" -eq 1 ] || exit 1
    printf 'Adding packages to the Nix profile; none will be removed.\n' >&2
    for attr in "${nix_attrs[@]}"; do
      nix profile add "nixpkgs#$attr"
    done
    ;;
  brew)
    printf 'Homebrew automatic installation is not supported; no changes made.\n' >&2
    printf 'Suggested command: brew install ffmpeg jq whisper-cpp\n' >&2
    exit 3
    ;;
  apt)
    printf 'apt automatic installation is not supported; no changes made.\n' >&2
    printf 'Suggested start: apt-get install ffmpeg jq; build whisper.cpp with a verified GPU backend.\n' >&2
    exit 3
    ;;
  none)
    printf 'No supported package manager detected; no changes made.\n' >&2
    exit 3
    ;;
  *) fail "invalid package manager override: $package_manager" ;;
esac
