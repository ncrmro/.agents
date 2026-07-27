#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$test_dir/.." && pwd)"
obs_dir="$(cd "$skill_dir/../obs-recording" && pwd)"
scratch=$(mktemp -d)
cleanup() {
  [ -n "${scratch:-}" ] && [ -d "$scratch" ] && rm -rf -- "$scratch"
}
trap cleanup EXIT
fake_bin="$scratch/bin"
mkdir "$fake_bin"
system_path=$PATH
export PATH="$fake_bin:$system_path"

pass=0
failures=0
ok() {
  pass=$((pass + 1))
  printf 'ok %d - %s\n' "$pass" "$1"
}
not_ok() {
  pass=$((pass + 1))
  failures=$((failures + 1))
  printf 'not ok %d - %s\n' "$pass" "$1"
}
assert() {
  description=$1
  shift
  if "$@"; then ok "$description"; else not_ok "$description"; fi
}
contains() {
  haystack=$1
  needle=$2
  case "$haystack" in *"$needle"*) return 0 ;; *) return 1 ;; esac
}

media="$scratch/fixture.mkv"
model="$scratch/model.bin"
printf 'fixture\n' >"$media"
printf 'model\n' >"$model"

cat >"$fake_bin/ffprobe" <<'FAKE'
#!/usr/bin/env bash
cat <<JSON
{"format":{"format_name":"matroska","duration":"4","size":"10"},"streams":[
{"index":0,"codec_type":"video","codec_name":"h264","width":1280,"height":720,"avg_frame_rate":"30/1"},
{"index":2,"codec_type":"audio","codec_name":"pcm_s16le","channels":2,"channel_layout":"stereo","sample_rate":"48000","tags":{"title":"${FAKE_STREAM_TITLE:-Mic}"}}
]}
JSON
FAKE

cat >"$fake_bin/ffmpeg" <<'FAKE'
#!/usr/bin/env bash
last=
for argument in "$@"; do last=$argument; done
if [ "$last" != "-" ]; then
  printf 'wave\n' >"$last"
else
  if [ "${FAKE_AUDIO_PROFILE:-normal}" = quiet ]; then
    cat >&2 <<'METRICS'
mean_volume: -43.8 dB
max_volume: -16.1 dB
I: -39.3 LUFS
LRA: 11.9 LU
Peak: -16.1 dBFS
METRICS
    exit 0
  fi
  cat >&2 <<'METRICS'
mean_volume: -20.0 dB
max_volume: -6.0 dB
I: -18.0 LUFS
LRA: 3.0 LU
Peak: -2.0 dBFS
METRICS
fi
FAKE

cat >"$fake_bin/whisper-cli" <<'FAKE'
#!/usr/bin/env bash
output=
txt=0
srt=0
json=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-file) output=$2; shift 2 ;;
    --output-txt) txt=1; shift ;;
    --output-srt) srt=1; shift ;;
    --output-json) json=1; shift ;;
    *) shift ;;
  esac
done
case "${FAKE_WHISPER_BACKEND:-vulkan}" in
  vulkan) printf 'whisper_backend_init: using Vulkan0 backend\n' ;;
  cuda) printf 'whisper_backend_init: using CUDA0 backend\n' ;;
  metal) printf 'ggml_metal_init: using Metal backend\n' ;;
  cpu) printf 'load_backend: loaded CPU backend libggml-cpu.so\n' ;;
esac
[ "$txt" -eq 0 ] || printf 'raw text\n' >"$output.txt"
[ "$srt" -eq 0 ] || printf '1\n00:00:00,000 --> 00:00:01,000\nraw\n' >"$output.srt"
[ "$json" -eq 0 ] || printf '{"segments":[{"t0":0,"t1":100}]}\n' >"$output.json"
FAKE

cat >"$fake_bin/python3" <<'FAKE'
#!/usr/bin/env bash
if [ "${FAKE_WHISPERX_BACKEND:-cpu}" = cuda ]; then
  printf 'cuda\tFake CUDA GPU\n'
else
  printf 'cpu\tCPU\n'
fi
FAKE

cat >"$fake_bin/whisperx" <<'FAKE'
#!/usr/bin/env bash
output_dir=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --output_dir) output_dir=$2; shift 2 ;;
    *) shift ;;
  esac
done
printf 'speaker text\n' >"$output_dir/audio.txt"
printf '1\n00:00:00,000 --> 00:00:01,000\n[SPEAKER_00] raw\n' \
  >"$output_dir/audio.srt"
printf '{"segments":[{"speaker":"SPEAKER_00"}]}\n' >"$output_dir/audio.json"
FAKE

chmod +x "$fake_bin"/*

run_case() {
  name=$1
  shift
  case_dir="$scratch/$name"
  mkdir "$case_dir"
  "$skill_dir/scripts/transcribe-media.sh" "$media" \
    --model "$model" --output-base "$case_dir/out" "$@"
}

gpu_json=$(FAKE_WHISPER_BACKEND=vulkan run_case gpu --diarize never --json)
assert "verified GPU selection" \
  test "$(printf '%s' "$gpu_json" | jq -r .asr.backend)" = vulkan

cpu_log="$scratch/cpu.log"
if FAKE_WHISPER_BACKEND=cpu run_case cpu --diarize never \
  >"$scratch/cpu.json" 2>"$cpu_log"
then
  cpu_json=$(cat "$scratch/cpu.json")
  assert "CPU-only is reported in metadata" \
    test "$(printf '%s' "$cpu_json" | jq -r .asr.backend)" = cpu
  assert "CPU fallback reason is visible" \
    contains "$(cat "$cpu_log")" "CPU fallback"
else
  not_ok "CPU-only fallback completes"
fi

if FAKE_WHISPER_BACKEND=cpu run_case strict --diarize never --require-gpu \
  >"$scratch/strict.out" 2>"$scratch/strict.err"
then
  not_ok "strict GPU refusal"
else
  assert "strict GPU refusal" \
    contains "$(cat "$scratch/strict.err")" "refused CPU transcription"
fi

cat >"$fake_bin/nix" <<'FAKE'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_NIX_LOG"
FAKE
chmod +x "$fake_bin/nix"
export FAKE_NIX_LOG="$scratch/nix.log"
TRANSCRIBE_PACKAGE_MANAGER=nix \
  "$skill_dir/scripts/install-remediation.sh" --install ffmpeg whisper \
  >"$scratch/nix.out" 2>"$scratch/nix.err"
assert "Nix install path adds ffmpeg" \
  contains "$(cat "$FAKE_NIX_LOG")" "profile add nixpkgs#ffmpeg"
assert "Nix install path chooses Vulkan whisper on Linux" \
  contains "$(cat "$FAKE_NIX_LOG")" "profile add nixpkgs#whisper-cpp-vulkan"

if TRANSCRIBE_PACKAGE_MANAGER=brew \
  "$skill_dir/scripts/install-remediation.sh" --install ffmpeg \
  >"$scratch/brew.out" 2>"$scratch/brew.err"
then
  not_ok "Homebrew automatic install makes no changes"
else
  assert "Homebrew automatic install makes no changes" \
    contains "$(cat "$scratch/brew.err")" "no changes made"
fi
if TRANSCRIBE_PACKAGE_MANAGER=apt \
  "$skill_dir/scripts/install-remediation.sh" --install ffmpeg \
  >"$scratch/apt.out" 2>"$scratch/apt.err"
then
  not_ok "apt automatic install makes no changes"
else
  assert "apt automatic install makes no changes" \
    contains "$(cat "$scratch/apt.err")" "no changes made"
fi

sibling_media="$scratch/sibling.mov"
printf 'fixture\n' >"$sibling_media"
FAKE_WHISPER_BACKEND=vulkan "$skill_dir/scripts/transcribe-media.sh" \
  "$sibling_media" --model "$model" --diarize never --json \
  >"$scratch/sibling-result.json"
assert "default output is sibling TXT" test -s "$scratch/sibling.txt"
assert "default output is sibling raw JSON" test -s "$scratch/sibling.json"

if FAKE_WHISPER_BACKEND=vulkan "$skill_dir/scripts/transcribe-media.sh" \
  "$sibling_media" --model "$model" --diarize never --json \
  >"$scratch/overwrite.out" 2>"$scratch/overwrite.err"
then
  not_ok "overwrite refusal"
else
  assert "overwrite refusal" \
    contains "$(cat "$scratch/overwrite.err")" "refusing to overwrite"
fi

never_json=$(FAKE_STREAM_TITLE="Meeting mix" HF_TOKEN=fake \
  run_case never --diarize never --json)
assert "diarize never never invokes labels" \
  test "$(printf '%s' "$never_json" | jq -r .diarization.selected)" = false

always_json=$(FAKE_STREAM_TITLE=Mic HF_TOKEN=fake \
  run_case always --diarize always --json)
assert "diarize always requires labels" \
  test "$(printf '%s' "$always_json" | jq -r .diarization.selected)" = true
assert "diarize always keeps raw labeled JSON" \
  test -s "$scratch/always/out.diarized.json"

auto_yes_json=$(FAKE_STREAM_TITLE="Interview guests" HF_TOKEN=fake \
  run_case auto-yes --diarize auto --json)
assert "auto diarizes an explicit multi-speaker title with prerequisites" \
  test "$(printf '%s' "$auto_yes_json" | jq -r .diarization.selected)" = true
auto_no_json=$(FAKE_STREAM_TITLE=Mic HF_TOKEN=fake \
  run_case auto-no --diarize auto --json)
assert "auto exposes conservative no-label decision" \
  contains "$(printf '%s' "$auto_no_json" | jq -r .diarization.decision)" \
    "not inferred"

cat >"$fake_bin/shared-transcriber" <<'FAKE'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$FAKE_OBS_ARGS"
cat <<'JSON'
{"asr":{"backend":"vulkan","device":"Vulkan0","reason":"verified"},"diarization":{"policy":"never","selected":false,"decision":"disabled","runtime":{"backend":"not-run"}},"outputs":{"text":"x.txt","srt":"x.srt","json":"x.json"}}
JSON
FAKE
chmod +x "$fake_bin/shared-transcriber"
export FAKE_OBS_ARGS="$scratch/obs-args"
OBS_TRANSCRIBE_COMMAND="$fake_bin/shared-transcriber" \
  node "$obs_dir/scripts/recording-check.mjs" "$media" \
  --audio-stream 2 --transcribe --diarize never \
  >"$scratch/obs-report.json"
assert "OBS report carries shared backend metadata" \
  test "$(jq -r .transcript.asr.backend "$scratch/obs-report.json")" = vulkan
assert "OBS delegates diarization policy" \
  contains "$(cat "$FAKE_OBS_ARGS")" "--diarize never"

FAKE_AUDIO_PROFILE=quiet node "$obs_dir/scripts/recording-check.mjs" "$media" \
  --audio-stream 2 >"$scratch/obs-quiet-report.json"
assert "OBS flags low integrated loudness even when a transient peak is higher" \
  test "$(jq -r '.audioStreams[0].findings[0].code' \
    "$scratch/obs-quiet-report.json")" = audio-quiet

printf '1..%d\n' "$pass"
[ "$failures" -eq 0 ]
