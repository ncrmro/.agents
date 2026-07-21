# Setup tools — Install and verify the media toolchain

Read this document when `ffmpeg`, `ffprobe`, `whisper-cli`, or `whisperx` is
missing, when the user asks to set up the media environment, or before starting
a job on a fresh machine.

## Fastest path: the dependency doctor

`scripts/deps-doctor.sh` checks everything below, detects the OS and package
manager, and prints exact install commands. It never mutates the system unless
you pass `--install`.

```bash
bash scripts/deps-doctor.sh            # report + copy-paste install commands
bash scripts/deps-doctor.sh --install  # install missing pieces (nix / brew / apt / uv / ollama)
bash scripts/deps-doctor.sh --json     # machine-readable, for preflight gating
```

Exit status is `0` when every required tool is present, `1` otherwise, so the
doctor doubles as a preflight in scripts and CI.

## Reproducible path: devenv

The skill ships a `devenv.nix` providing the full toolchain (GPU-accelerated
`whisper-cpp-vulkan` + `whisperx` + ffmpeg + docling). Enter it, or run one
command inside it:

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

## Nix (any OS)

Preferred when a project has a devshell. Ad hoc or persistent:

```bash
nix shell nixpkgs#ffmpeg nixpkgs#whisper-cpp-vulkan nixpkgs#whisperx
# or persistently:
nix profile add nixpkgs#ffmpeg nixpkgs#whisper-cpp-vulkan nixpkgs#whisperx
```

- On NixOS/Linux with a GPU, `whisper-cpp-vulkan` uses the Vulkan backend
  automatically (needs mesa/RADV drivers); it falls back to CPU otherwise.
- `whisperx`'s torch runs on CPU on non-CUDA machines — fine, just slower.
- `nixpkgs#docling` is currently broken; install it via `uv tool install docling`.

## Debian/Ubuntu (apt)

ffmpeg is packaged; whisper.cpp is not — build from source:

```bash
sudo apt-get update
sudo apt-get install -y ffmpeg build-essential cmake git
git clone https://github.com/ggml-org/whisper.cpp ~/.local/src/whisper.cpp
cmake -S ~/.local/src/whisper.cpp -B ~/.local/src/whisper.cpp/build -DCMAKE_BUILD_TYPE=Release
cmake --build ~/.local/src/whisper.cpp/build -j --config Release
sudo cp ~/.local/src/whisper.cpp/build/bin/whisper-cli /usr/local/bin/
uv tool install whisperx docling
```

(For NVIDIA GPUs add `-DGGML_CUDA=1` to the first cmake call — requires the CUDA
toolkit. For AMD, use `-DGGML_VULKAN=1`.)

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
<https://hf.co/settings/tokens>, accept the terms at
<https://hf.co/pyannote/speaker-diarization-3.1>, then `export HF_TOKEN=…`.

## Verify

Quiet preflight — prints only problems:

```bash
bash scripts/deps-doctor.sh -q
```

Optional end-to-end smoke test — 3 s of silence transcribed without errors:

```bash
ffmpeg -y -f lavfi -i anullsrc=r=16000:cl=mono -t 3 /tmp/smoke.wav
whisper-cli -m "$WHISPER_MODEL_DIR"/ggml-*.bin -f /tmp/smoke.wav --output-srt --output-file /tmp/smoke
```

Report what was installed, from where, and any tool that still needs manual
attention.
