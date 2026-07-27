# Setup tools — Install and verify the media toolchain

Read this document when `ffmpeg`, `ffprobe`, `whisper-cli`, or `whisperx` is
missing, when the user asks to set up the media environment, or before starting
a job on a fresh machine.

## Transcription preflight and explicit remediation

`scripts/toolchain-doctor.sh` checks ffmpeg, jq, whisper.cpp, the model, and
diarization prerequisites. It never changes the system unless you pass
`--install`. Automatic installation supports Nix only; Homebrew and apt print
suggested manual steps and exit without making changes.

```bash
bash scripts/toolchain-doctor.sh            # report requirements
bash scripts/toolchain-doctor.sh --install  # add missing commands to a Nix profile
bash scripts/toolchain-doctor.sh --json     # machine-readable preflight
```

Exit status is `0` when every required tool is present, `1` otherwise, so the
doctor doubles as a preflight in scripts and CI. Run `scripts/deps-doctor.sh`
for the broader media toolchain, including optional Docling and Ollama checks.

## Reproducible path: devenv

The skill ships a `devenv.nix` providing the full toolchain (GPU-accelerated
whisper.cpp on supported platforms + `whisperx` + ffmpeg). Enter it, or run one
command inside it. A package being present is not GPU proof; the transcription
command performs the runtime check.

```bash
devenv shell                 # full toolchain on PATH
devenv shell -- deps-doctor  # run the doctor inside the env
devenv test                  # verify the toolchain runs
```

Copy `packages` / `enterShell` / `enterTest` into a consuming repo's own
`devenv.nix` to give that project the same toolchain.

## What's needed

| Tool | Provides | Check |
|------|----------|-------|
| ffmpeg / ffprobe | Cutting, speed filters, encoding, audio extraction, metadata | `ffmpeg -version` |
| whisper.cpp | `whisper-cli` — local timestamped speech-to-text | `whisper-cli --help` |
| whisper model | ggml model file for whisper-cli | `ls $WHISPER_MODEL_DIR/ggml-*.bin` |
| whisperx | Multi-speaker diarization (faster-whisper + pyannote) | `command -v whisperx` |
| HF token | Gated pyannote weights for whisperx `--diarize` | `echo $HF_TOKEN` |
| docling *(optional)* | PDF → markdown | `docling --version` |
| Ollama + LLM *(optional)* | Transcript post-processing (speaker naming, cleanup) — **not** ASR | `curl -fs $OLLAMA_HOST/api/version` |

## Detect the environment first

1. `uname -s` — `Darwin` → Homebrew; `Linux` → check further.
2. On Linux: if `nix` is on PATH (or a `devenv.nix`/`flake.nix` is present),
   prefer Nix; else if `apt-get` exists → Debian/Ubuntu; else report what package
   managers exist and ask.
3. Check what's already installed before installing anything — only fill gaps
   (the doctor does this for you).

## macOS (Homebrew)

```bash
brew install ffmpeg whisper-cpp
uv tool install whisperx docling   # or: pipx install whisperx
```

Homebrew's `whisper-cpp` ships `whisper-cli`; on Apple Silicon it is Metal-built.

## Nix

Preferred when a project has a devshell. Ad hoc (non-persistent) or explicit
profile installation:

```bash
# Linux
nix shell nixpkgs#ffmpeg nixpkgs#whisper-cpp-vulkan nixpkgs#whisperx
nix profile add nixpkgs#ffmpeg nixpkgs#whisper-cpp-vulkan nixpkgs#whisperx
# macOS
nix shell nixpkgs#ffmpeg nixpkgs#whisper-cpp nixpkgs#whisperx
nix profile add nixpkgs#ffmpeg nixpkgs#whisper-cpp nixpkgs#whisperx
```

- On NixOS/Linux, `whisper-cpp-vulkan` provides the Vulkan-capable build. The
  transcription command classifies the active backend from its runtime log.
- `whisperx`'s torch runs on CPU on non-CUDA machines — fine, just slower.
- `nixpkgs#docling` is currently broken; install it via `uv tool install docling`.

## Debian/Ubuntu (apt)

The transcription installer does not support apt. It prints suggested manual
steps and makes no changes. Any future source-build flow must select Vulkan or
CUDA explicitly and verify the backend from its runtime log.

## Whisper model

whisper-cli needs a ggml model file. Convention: `$WHISPER_MODEL_DIR`
(default `~/.cache/whisper`).

```bash
mkdir -p "$WHISPER_MODEL_DIR"
# Best accuracy for narration (~3 GB). Ask before downloading.
curl -L -o "$WHISPER_MODEL_DIR/ggml-large-v3.bin" \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin
# Fast English-only fallback for rough cuts (~140 MB)
curl -L -o "$WHISPER_MODEL_DIR/ggml-base.en.bin" \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin
```

Model downloads are large — run them as background tasks, and always ask the
user before pulling the large model.

## HF token (for whisperx diarization)

pyannote's diarization weights are gated. Create a token at
<https://hf.co/settings/tokens> and accept access to
<https://hf.co/pyannote/speaker-diarization-community-1>, the bundled workflow's
default. Direct runs using `speaker-diarization-3.1` also require access to that
model and `pyannote/segmentation-3.0`.

Store it in a **gitignored `.env`** in the skill root (`.env` and `.env.*` are
ignored; `.env.example` is the template):

```bash
cp .env.example .env
# then set HF_TOKEN=hf_... in .env
```

The devenv, `scripts/deps-doctor.sh`, and `scripts/transcribe-media.sh` load
`.env`. It can also override `OLLAMA_HOST`, `NEMOTRON_MODEL`,
`WHISPER_MODEL_DIR`, and `WHISPER_MODEL`. A plain `export HF_TOKEN=…` still
works.

## Verify

Run the transcription preflight:

```bash
bash scripts/toolchain-doctor.sh
```

Optional end-to-end smoke test — 3 s of silence transcribed without errors:

```bash
ffmpeg -y -f lavfi -i anullsrc=r=16000:cl=mono -t 3 /tmp/smoke.wav
whisper-cli -m "$WHISPER_MODEL_DIR"/ggml-*.bin -f /tmp/smoke.wav --output-srt --output-file /tmp/smoke
```

Report what was installed, from where, and any tool that still needs manual
attention.
