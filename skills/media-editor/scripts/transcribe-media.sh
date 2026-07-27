#!/usr/bin/env bash
# Stable user-facing entry point; orchestration lives in transcribe-run.sh.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$script_dir/transcribe-run.sh" "$@"
