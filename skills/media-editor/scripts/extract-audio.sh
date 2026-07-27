#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: extract-audio.sh FILE OUTPUT.wav [--audio-stream INDEX] [--duration SECONDS]

Extract clean 16 kHz mono PCM audio for speech recognition. OUTPUT must not
already exist. INDEX is the absolute ffmpeg stream index; the first audio stream
is used by default.
EOF
}

fail() {
  printf 'extract-audio: %s\n' "$*" >&2
  exit 2
}

[ "$#" -gt 0 ] || { usage >&2; exit 2; }
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

[ "$#" -ge 2 ] || fail "FILE and OUTPUT.wav are required"
input=$1
output=$2
shift 2
audio_stream=
duration=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --audio-stream)
      [ "$#" -ge 2 ] || fail "--audio-stream requires an index"
      audio_stream=$2
      shift 2
      ;;
    --duration)
      [ "$#" -ge 2 ] || fail "--duration requires seconds"
      duration=$2
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[ -f "$input" ] || fail "file does not exist: $input"
[ ! -e "$output" ] || fail "refusing to overwrite: $output"
command -v ffmpeg >/dev/null 2>&1 || fail "ffmpeg is not available on PATH"

args=(-hide_banner -loglevel error -nostdin -i "$input")
if [ -n "$audio_stream" ]; then
  case "$audio_stream" in *[!0-9]*) fail "audio stream must be an integer" ;; esac
  args+=(-map "0:$audio_stream")
else
  args+=(-map "0:a:0")
fi
[ -z "$duration" ] || args+=(-t "$duration")
args+=(-vn -acodec pcm_s16le -ar 16000 -ac 1 "$output")

ffmpeg "${args[@]}"
[ -s "$output" ] || fail "ffmpeg did not create audio: $output"
