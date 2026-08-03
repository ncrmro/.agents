#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
RENDER=$TEST_DIR/../scripts/render-narration.sh
TMP=$(mktemp -d "${TMPDIR:-/tmp}/video-director-narration-test.XXXXXX")
trap 'rm -rf -- "$TMP"' EXIT INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

for tool in ffmpeg ffprobe jq; do
  command -v "$tool" >/dev/null 2>&1 || fail "$tool is required for this test."
done

mkdir -p "$TMP/bin" "$TMP/log"
export TEST_LOG=$TMP/log
export TEST_AUDIO=$TMP/provider-fixture.wav
export REAL_FFMPEG
REAL_FFMPEG=$(command -v ffmpeg)

ffmpeg -y -loglevel error -f lavfi -i 'sine=frequency=440:duration=0.15' \
  -ar 22050 -ac 1 -c:a pcm_s16le "$TEST_AUDIO"

cat >"$TMP/bin/piper" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
input=
output=
while [ $# -gt 0 ]; do
  case "$1" in
    --input-file) input=$2; shift 2 ;;
    --output-file) output=$2; shift 2 ;;
    --model|--config) shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$input" ] && [ -n "$output" ]
cat "$input" >>"$TEST_LOG/piper-lines.txt"
"$REAL_FFMPEG" -y -loglevel error -f lavfi \
  -i 'sine=frequency=440:duration=0.08' \
  -ar 22050 -ac 1 -c:a pcm_s16le "$output"
EOF

cat >"$TMP/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"$TEST_LOG/curl.args"
output=
payload=
config=
url=
while [ $# -gt 0 ]; do
  case "$1" in
    --output) output=$2; shift 2 ;;
    --data-binary) payload=${2#@}; shift 2 ;;
    --config) config=$2; shift 2 ;;
    --url) url=$2; shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$output" ] && [ -n "$payload" ] && [ -n "$config" ] && [ -n "$url" ]
cp "$payload" "$TEST_LOG/request.json"
printf '%s\n' "$url" >"$TEST_LOG/url.txt"
cp "$config" "$TEST_LOG/curl.conf"
cp "$TEST_AUDIO" "$output"
EOF

chmod +x "$TMP/bin/piper" "$TMP/bin/curl" "$RENDER"

cat >"$TMP/narration.txt" <<'EOF'
One Markdown file defines this reviewer.
The review identifies one adoption blocker.
EOF
touch "$TMP/voice.onnx" "$TMP/voice.onnx.json"

PATH="$TMP/bin:$PATH" "$RENDER" \
  --provider piper \
  --script "$TMP/narration.txt" \
  --output "$TMP/piper.wav" \
  --native-output "$TMP/piper-native.wav" \
  --piper-model "$TMP/voice.onnx" >/dev/null

[ -s "$TMP/piper.wav" ] || fail "Piper output is missing."
[ -s "$TMP/piper-native.wav" ] || fail "Piper native output is missing."
[ "$(wc -l <"$TMP/log/piper-lines.txt")" -eq 2 ] ||
  fail "Piper did not render one take for each script line."
[ "$(ffprobe -v error -select_streams a:0 \
  -show_entries stream=sample_rate,channels -of csv=p=0 "$TMP/piper.wav")" = '48000,2' ] ||
  fail "Piper output is not normalized to 48 kHz stereo."

test_key=local_test_key
ELEVENLABS_API_KEY=$test_key \
PATH="$TMP/bin:$PATH" "$RENDER" \
  --provider elevenlabs \
  --script "$TMP/narration.txt" \
  --output "$TMP/elevenlabs.wav" \
  --native-output "$TMP/elevenlabs-native.wav" \
  --voice-id voice123 \
  --model-id eleven_multilingual_v2 \
  --seed 7 \
  --confirm-external >/dev/null

[ -s "$TMP/elevenlabs.wav" ] || fail "ElevenLabs output is missing."
[ -s "$TMP/elevenlabs-native.wav" ] || fail "ElevenLabs native output is missing."
[ "$(ffprobe -v error -select_streams a:0 \
  -show_entries stream=sample_rate,channels -of csv=p=0 "$TMP/elevenlabs.wav")" = '48000,2' ] ||
  fail "ElevenLabs output is not normalized to 48 kHz stereo."
jq -e \
  '.model_id == "eleven_multilingual_v2"
   and .seed == 7
   and (.text | contains("One Markdown file"))' \
  "$TMP/log/request.json" >/dev/null ||
  fail "ElevenLabs request payload is incorrect."
grep -F '/v1/text-to-speech/voice123?output_format=mp3_44100_128' \
  "$TMP/log/url.txt" >/dev/null ||
  fail "ElevenLabs request URL is incorrect."
if grep -F "$test_key" "$TMP/log/curl.args" >/dev/null; then
  fail "ElevenLabs API key appears in curl arguments."
fi
grep -F "xi-api-key: $test_key" "$TMP/log/curl.conf" >/dev/null ||
  fail "ElevenLabs API key is missing from the curl configuration."

key_file=$TMP/elevenlabs-api-key
file_test_key=file_test_key
printf '%s\n' "$file_test_key" >"$key_file"
env -u ELEVENLABS_API_KEY PATH="$TMP/bin:$PATH" "$RENDER" \
  --provider elevenlabs \
  --script "$TMP/narration.txt" \
  --output "$TMP/elevenlabs-key-file.wav" \
  --api-key-file "$key_file" \
  --voice-id voice123 \
  --confirm-external >/dev/null
grep -F "xi-api-key: $file_test_key" "$TMP/log/curl.conf" >/dev/null ||
  fail "ElevenLabs API key file was not used."
if grep -F "$file_test_key" "$TMP/log/curl.args" >/dev/null; then
  fail "ElevenLabs API key from the file appears in curl arguments."
fi

if ELEVENLABS_API_KEY=$test_key PATH="$TMP/bin:$PATH" "$RENDER" \
  --provider elevenlabs \
  --script "$TMP/narration.txt" \
  --output "$TMP/no-confirm.wav" \
  --voice-id voice123 >"$TMP/no-confirm.out" 2>"$TMP/no-confirm.err"; then
  fail "ElevenLabs request ran without --confirm-external."
fi
grep -F 'Get user approval' "$TMP/no-confirm.err" >/dev/null ||
  fail "Missing ElevenLabs approval did not explain the required action."

if env -u ELEVENLABS_API_KEY PATH="$TMP/bin:$PATH" "$RENDER" \
  --provider elevenlabs \
  --script "$TMP/narration.txt" \
  --output "$TMP/no-key.wav" \
  --api-key-file "$TMP/missing-key" \
  --voice-id voice123 \
  --confirm-external >"$TMP/no-key.out" 2>"$TMP/no-key.err"; then
  fail "ElevenLabs request ran without an API key."
fi
grep -F 'Set ELEVENLABS_API_KEY or provide a readable API key file' \
  "$TMP/no-key.err" >/dev/null ||
  fail "Missing ElevenLabs key did not explain the required sources."

printf '%s\n' 'video-director narration providers: ok'
