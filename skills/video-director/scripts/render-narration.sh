#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/require.sh"

usage() {
  cat <<'EOF'
Usage:
  render-narration.sh --provider piper --script FILE --output FILE.wav \
    --piper-model FILE.onnx [options]

  render-narration.sh --provider elevenlabs --script FILE --output FILE.wav \
    --voice-id ID --confirm-external [options]

Common options:
  --provider NAME          piper or elevenlabs
  --script FILE            Narration text. Use one sentence per non-empty line.
  --output FILE.wav        Normalized 48 kHz stereo PCM WAV.
  --native-output FILE     Keep the provider audio before normalization.
  --force                  Replace existing output files.

Piper options:
  --piper-model FILE       Piper ONNX voice model. PIPER_MODEL also works.
  --piper-config FILE      Piper JSON model configuration.
  --segment-pause SECONDS  Pause between script lines. Default: 0.28.

ElevenLabs options:
  --voice-id ID            Voice ID. ELEVENLABS_VOICE_ID also works.
  --model-id ID            Model ID. Default: eleven_multilingual_v2.
  --output-format FORMAT   API output format. Default: mp3_44100_128.
  --language-code CODE     Optional ISO 639-1 language code.
  --seed NUMBER            Optional deterministic seed.
  --zero-retention         Request zero retention. Enterprise support required.
  --confirm-external       Confirm user approval for the paid service request.

The ElevenLabs API key must be in ELEVENLABS_API_KEY.
EOF
}

fail() {
  printf '%s: %s\n' "${0##*/}" "$1" >&2
  exit 1
}

provider=
script_file=
output=
native_output=
force=false

piper_model=${PIPER_MODEL:-}
piper_config=${PIPER_CONFIG:-}
segment_pause=0.28

elevenlabs_voice_id=${ELEVENLABS_VOICE_ID:-}
elevenlabs_model_id=${ELEVENLABS_MODEL_ID:-eleven_multilingual_v2}
elevenlabs_output_format=${ELEVENLABS_OUTPUT_FORMAT:-mp3_44100_128}
language_code=
seed=
zero_retention=false
confirm_external=false

while [ $# -gt 0 ]; do
  case "$1" in
    --provider)
      [ $# -ge 2 ] || fail "--provider needs a value."
      provider=$2
      shift 2
      ;;
    --script)
      [ $# -ge 2 ] || fail "--script needs a value."
      script_file=$2
      shift 2
      ;;
    --output)
      [ $# -ge 2 ] || fail "--output needs a value."
      output=$2
      shift 2
      ;;
    --native-output)
      [ $# -ge 2 ] || fail "--native-output needs a value."
      native_output=$2
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    --piper-model)
      [ $# -ge 2 ] || fail "--piper-model needs a value."
      piper_model=$2
      shift 2
      ;;
    --piper-config)
      [ $# -ge 2 ] || fail "--piper-config needs a value."
      piper_config=$2
      shift 2
      ;;
    --segment-pause)
      [ $# -ge 2 ] || fail "--segment-pause needs a value."
      segment_pause=$2
      shift 2
      ;;
    --voice-id)
      [ $# -ge 2 ] || fail "--voice-id needs a value."
      elevenlabs_voice_id=$2
      shift 2
      ;;
    --model-id)
      [ $# -ge 2 ] || fail "--model-id needs a value."
      elevenlabs_model_id=$2
      shift 2
      ;;
    --output-format)
      [ $# -ge 2 ] || fail "--output-format needs a value."
      elevenlabs_output_format=$2
      shift 2
      ;;
    --language-code)
      [ $# -ge 2 ] || fail "--language-code needs a value."
      language_code=$2
      shift 2
      ;;
    --seed)
      [ $# -ge 2 ] || fail "--seed needs a value."
      seed=$2
      shift 2
      ;;
    --zero-retention)
      zero_retention=true
      shift
      ;;
    --confirm-external)
      confirm_external=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown option: $1"
      ;;
  esac
done

[ "$provider" = piper ] || [ "$provider" = elevenlabs ] ||
  fail "--provider must be piper or elevenlabs."
[ -n "$script_file" ] || fail "--script is required."
[ -f "$script_file" ] || fail "script file does not exist: $script_file"
[ -r "$script_file" ] || fail "script file is not readable: $script_file"
[ -s "$script_file" ] || fail "script file is empty: $script_file"
[ -n "$output" ] || fail "--output is required."
case "$output" in
  *.wav) ;;
  *) fail "--output must use the .wav file extension." ;;
esac
[ "$script_file" != "$output" ] || fail "--script and --output must be different files."
[ -z "$native_output" ] || [ "$native_output" != "$output" ] ||
  fail "--native-output and --output must be different files."
[ -z "$native_output" ] || [ "$native_output" != "$script_file" ] ||
  fail "--native-output and --script must be different files."

if [ "$force" = false ]; then
  [ ! -e "$output" ] || fail "output exists; use --force to replace it: $output"
  if [ -n "$native_output" ]; then
    [ ! -e "$native_output" ] ||
      fail "native output exists; use --force to replace it: $native_output"
  fi
fi

require_tool ffmpeg \
  "nix profile install nixpkgs#ffmpeg" \
  "brew install ffmpeg"
require_tool ffprobe \
  "nix profile install nixpkgs#ffmpeg" \
  "brew install ffmpeg"

case "$provider" in
  piper)
    require_tool piper \
      "nix profile install nixpkgs#piper-tts" \
      "pipx install piper-tts"
    [ -n "$piper_model" ] || fail "--piper-model or PIPER_MODEL is required."
    [ -f "$piper_model" ] || fail "Piper model does not exist: $piper_model"
    if [ -z "$piper_config" ]; then
      piper_config="${piper_model}.json"
    fi
    [ -f "$piper_config" ] || fail "Piper configuration does not exist: $piper_config"
    [[ "$segment_pause" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
      fail "--segment-pause must be zero or a positive number."
    ;;
  elevenlabs)
    require_tool curl \
      "nix profile install nixpkgs#curl" \
      "brew install curl"
    require_tool jq \
      "nix profile install nixpkgs#jq" \
      "brew install jq"
    [ "$confirm_external" = true ] ||
      fail "ElevenLabs can use credits and receives the script. Get user approval, then add --confirm-external."
    [ -n "${ELEVENLABS_API_KEY:-}" ] ||
      fail "ELEVENLABS_API_KEY is required for the ElevenLabs provider."
    [[ "$ELEVENLABS_API_KEY" =~ ^[A-Za-z0-9._-]+$ ]] ||
      fail "ELEVENLABS_API_KEY contains an unsupported character."
    [ -n "$elevenlabs_voice_id" ] ||
      fail "--voice-id or ELEVENLABS_VOICE_ID is required."
    [[ "$elevenlabs_voice_id" =~ ^[A-Za-z0-9_-]+$ ]] ||
      fail "--voice-id contains an unsupported character."
    [[ "$elevenlabs_model_id" =~ ^[A-Za-z0-9_.-]+$ ]] ||
      fail "--model-id contains an unsupported character."
    [[ "$elevenlabs_output_format" =~ ^[a-z0-9_]+$ ]] ||
      fail "--output-format contains an unsupported character."
    if [ -n "$language_code" ]; then
      [[ "$language_code" =~ ^[A-Za-z]{2}(-[A-Za-z]{2})?$ ]] ||
        fail "--language-code must be an ISO 639-1 code."
    fi
    if [ -n "$seed" ]; then
      [[ "$seed" =~ ^[0-9]+$ ]] ||
        fail "--seed must be a whole number."
      (( seed <= 4294967295 )) ||
        fail "--seed must not be greater than 4294967295."
    fi
    ;;
esac

output_dir=$(dirname -- "$output")
mkdir -p "$output_dir"
if [ -n "$native_output" ]; then
  mkdir -p "$(dirname -- "$native_output")"
fi

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/video-director-narration.XXXXXX")
output_candidate="${output%.wav}.tmp.$$.wav"
trap 'rm -rf -- "$work_dir"; rm -f -- "$output_candidate"' EXIT INT TERM
umask 077
native_audio="$work_dir/provider-audio"

render_piper() {
  local -a segments=()
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ [^[:space:]] ]]; then
      segments+=("$line")
    fi
  done <"$script_file"
  [ "${#segments[@]}" -gt 0 ] || fail "script has no non-empty lines."

  local concat_file="$work_dir/concat.txt"
  local pause_file="$work_dir/pause.wav"
  ffmpeg -y -loglevel error -f lavfi \
    -i "anullsrc=r=22050:cl=mono" -t "$segment_pause" \
    -c:a pcm_s16le "$pause_file"

  local index=0
  local segment
  for segment in "${segments[@]}"; do
    index=$((index + 1))
    local input_file
    local clip_file
    input_file=$(printf '%s/segment-%03d.txt' "$work_dir" "$index")
    clip_file=$(printf '%s/segment-%03d.wav' "$work_dir" "$index")
    printf '%s\n' "$segment" >"$input_file"
    piper \
      --model "$piper_model" \
      --config "$piper_config" \
      --input-file "$input_file" \
      --output-file "$clip_file"
    ffprobe -v error -select_streams a:0 -show_entries stream=index \
      -of csv=p=0 "$clip_file" >/dev/null ||
      fail "Piper did not create valid audio for script line $index."
    printf "file '%s'\n" "$clip_file" >>"$concat_file"
    if [ "$index" -lt "${#segments[@]}" ]; then
      printf "file '%s'\n" "$pause_file" >>"$concat_file"
    fi
  done

  ffmpeg -y -loglevel error -f concat -safe 0 -i "$concat_file" \
    -c:a pcm_s16le "${native_audio}.wav"
  native_audio="${native_audio}.wav"
}

render_elevenlabs() {
  local request_file="$work_dir/request.json"
  local curl_config="$work_dir/curl.conf"
  local seed_json=${seed:-null}
  jq -n \
    --rawfile text "$script_file" \
    --arg model_id "$elevenlabs_model_id" \
    --arg language_code "$language_code" \
    --argjson seed "$seed_json" \
    '
      {text: $text, model_id: $model_id}
      + (if $language_code == "" then {} else {language_code: $language_code} end)
      + (if $seed == null then {} else {seed: $seed} end)
    ' >"$request_file"

  printf 'header = "xi-api-key: %s"\n' "$ELEVENLABS_API_KEY" >"$curl_config"
  chmod 600 "$curl_config"

  local endpoint
  endpoint="https://api.elevenlabs.io/v1/text-to-speech/${elevenlabs_voice_id}?output_format=${elevenlabs_output_format}"
  if [ "$zero_retention" = true ]; then
    endpoint="${endpoint}&enable_logging=false"
  fi

  curl \
    --config "$curl_config" \
    --fail-with-body \
    --silent \
    --show-error \
    --connect-timeout 15 \
    --max-time 300 \
    --request POST \
    --url "$endpoint" \
    --header "Content-Type: application/json" \
    --data-binary "@$request_file" \
    --output "$native_audio"

  ffprobe -v error -select_streams a:0 -show_entries stream=index \
    -of csv=p=0 "$native_audio" >/dev/null ||
    fail "ElevenLabs did not return valid audio."
}

case "$provider" in
  piper) render_piper ;;
  elevenlabs) render_elevenlabs ;;
esac

ffmpeg -y -loglevel error -i "$native_audio" -vn \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
  -ar 48000 -ac 2 -c:a pcm_s16le "$output_candidate"
ffprobe -v error -select_streams a:0 \
  -show_entries stream=sample_rate,channels -of csv=p=0 \
  "$output_candidate" | grep -Fx '48000,2' >/dev/null ||
  fail "normalized narration is not 48 kHz stereo audio."

if [ -n "$native_output" ]; then
  cp -- "$native_audio" "$native_output"
  chmod 0644 "$native_output"
fi
mv -- "$output_candidate" "$output"
chmod 0644 "$output"

printf 'Narration provider: %s\n' "$provider"
printf 'Narration output: %s\n' "$output"
if [ -n "$native_output" ]; then
  printf 'Native provider audio: %s\n' "$native_output"
fi
