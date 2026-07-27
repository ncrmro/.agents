#!/usr/bin/env bash
# Thin OBS adapter: keep all transcription policy in media-editor.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared_default="$script_dir/../../media-editor/scripts/transcribe-media.sh"
shared_command=${MEDIA_EDITOR_TRANSCRIBE:-$shared_default}

[ -x "$shared_command" ] || {
  printf 'transcribe-recording: shared media-editor command is unavailable: %s\n' \
    "$shared_command" >&2
  exit 2
}

exec "$shared_command" "$@"
