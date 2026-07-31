#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$test_dir/.." && pwd)"
scratch="$(mktemp -d)"
cleanup() {
  [ -d "${scratch:-}" ] && rm -rf -- "$scratch"
}
trap cleanup EXIT

fake_home="$scratch/home"
fake_bin="$scratch/bin"
fake_profile="$fake_home/.nix-profile"
system_jq="$(command -v jq)"
system_path="$PATH"
mkdir -p "$fake_home/.local/bin" "$fake_bin" "$fake_profile/bin" \
  "$fake_profile/lib" "$fake_home/.cache/whisper"

pass=0
failures=0
ok() { pass=$((pass + 1)); printf 'ok %d - %s\n' "$pass" "$1"; }
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
contains() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }

cat >"$fake_bin/nix" <<'FAKE'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_NIX_LOG"
FAKE
cat >"$fake_bin/uv" <<'FAKE'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FAKE_UV_LOG"
FAKE
cat >"$fake_bin/curl" <<'FAKE'
#!/usr/bin/env bash
output=
while [ "$#" -gt 0 ]; do
  case "$1" in --output) output=$2; shift 2 ;; *) shift ;; esac
done
printf 'model\n' >"$output"
FAKE
chmod +x "$fake_bin"/*

export HOME="$fake_home"
export PATH="$fake_bin:$system_path"
export SOURCE_INGEST_NIX_PROFILE="$fake_profile"
export FAKE_NIX_LOG="$scratch/nix.log"
export FAKE_UV_LOG="$scratch/uv.log"

cat >"$fake_profile/bin/ffmpeg" <<'FAKE'
#!/usr/bin/env bash
last=
for argument in "$@"; do last=$argument; done
case "$*" in *-version*) printf 'ffmpeg fake\n' ;; *) printf 'wave\n' >"$last" ;; esac
FAKE
cat >"$fake_profile/bin/ffprobe" <<'FAKE'
#!/usr/bin/env bash
case "$*" in *-version*) printf 'ffprobe fake\n' ;; *) printf '1.0\n' ;; esac
FAKE
cat >"$fake_profile/bin/docling" <<'FAKE'
#!/usr/bin/env bash
printf 'docling fake\n'
FAKE
cat >"$fake_profile/bin/whisper-cli" <<'FAKE'
#!/usr/bin/env bash
if [ "${1:-}" = --version ]; then
  printf 'ggml_vulkan: 0 = Fake AMD GPU (RADV)\n' >&2
  printf 'load_backend: loaded Vulkan backend libggml-vulkan.so\n' >&2
  exit 0
fi
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
printf 'ggml_vulkan: 0 = Fake AMD GPU (RADV)\n'
printf 'load_backend: loaded Vulkan backend libggml-vulkan.so\n'
[ "$txt" -eq 0 ] || printf 'text\n' >"$output.txt"
[ "$srt" -eq 0 ] || printf '1\n00:00:00,000 --> 00:00:01,000\ntext\n' >"$output.srt"
[ "$json" -eq 0 ] || printf '{"segments":[]}\n' >"$output.json"
FAKE
chmod +x "$fake_profile/bin"/*
ln -s "$system_jq" "$fake_profile/bin/jq"
printf 'model\n' >"$fake_home/.cache/whisper/ggml-small.en-tdrz.bin"

doctor_json="$("$skill_dir/scripts/toolchain-doctor.sh" --json)"
assert "doctor verifies Vulkan" \
  test "$(jq -r .whisper.backend <<<"$doctor_json")" = vulkan
assert "doctor records device" \
  test "$(jq -r .whisper.device <<<"$doctor_json")" = "Fake AMD GPU"
assert "profile whisper wins PATH" \
  contains "$(jq -r .whisper.binary <<<"$doctor_json")" "$fake_profile"

media="$scratch/media.m4a"
printf 'media\n' >"$media"
transcript_json="$("$skill_dir/scripts/transcribe.sh" "$media" \
  --output-base "$scratch/out" --tinydiarize)"
assert "transcribe records Vulkan" \
  test "$(jq -r .asr.backend <<<"$transcript_json")" = vulkan
assert "transcribe writes raw SRT" test -s "$scratch/out.srt"
assert "transcribe preserves runtime log" test -s "$scratch/out.whisper.log"

cat >"$fake_profile/bin/whisper-cli" <<'FAKE'
#!/usr/bin/env bash
printf 'load_backend: loaded CPU backend libggml-cpu.so\n' >&2
FAKE
chmod +x "$fake_profile/bin/whisper-cli"
if "$skill_dir/scripts/toolchain-doctor.sh" >"$scratch/cpu.out" 2>"$scratch/cpu.err"; then
  not_ok "CPU fails closed"
else
  ok "CPU fails closed"
fi
assert "CPU override is explicit" \
  "$skill_dir/scripts/toolchain-doctor.sh" --allow-cpu

cat >"$fake_profile/bin/whisper-cli" <<'FAKE'
#!/usr/bin/env bash
printf 'load_backend: loaded Vulkan backend libggml-vulkan.so\n' >&2
printf 'load_backend: loaded CPU backend libggml-cpu.so\n' >&2
FAKE
chmod +x "$fake_profile/bin/whisper-cli"
if "$skill_dir/scripts/toolchain-doctor.sh" \
  >"$scratch/hidden-device.out" 2>"$scratch/hidden-device.err"; then
  not_ok "Vulkan library without a device fails closed"
else
  ok "Vulkan library without a device fails closed"
fi

rm -f "$fake_home/.cache/whisper/ggml-small.en-tdrz.bin"
cat >"$fake_profile/bin/whisper-cli" <<'FAKE'
#!/usr/bin/env bash
printf 'ggml_vulkan: 0 = Fake AMD GPU (RADV)\n' >&2
printf 'load_backend: loaded Vulkan backend libggml-vulkan.so\n' >&2
FAKE
chmod +x "$fake_profile/bin/whisper-cli"
"$skill_dir/scripts/setup-tools.sh" >"$scratch/setup.out" 2>"$scratch/setup.err"
assert "setup selects Vulkan priority 4" \
  contains "$(cat "$FAKE_NIX_LOG")" \
  "profile add --profile $fake_profile --priority 4 nixpkgs#whisper-cpp-vulkan"
assert "setup installs core Nix tools" \
  contains "$(cat "$FAKE_NIX_LOG")" "nixpkgs#ffmpeg"
assert "setup installs default model" \
  test -s "$fake_home/.cache/whisper/ggml-small.en-tdrz.bin"

printf '1..%d\n' "$pass"
[ "$failures" -eq 0 ]
