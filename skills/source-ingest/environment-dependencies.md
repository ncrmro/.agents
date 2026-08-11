# Environment dependencies

## Nix/NixOS default

The skill owns its reusable toolchain. Do not require every consuming project
to add transcription or PDF-ingest packages to its devenv.

Run:

```bash
scripts/setup-tools.sh
scripts/toolchain-doctor.sh
```

The setup script installs these into the user profile:

- `ffmpeg` / `ffprobe`;
- `jq`;
- `uv`;
- `whisper-cpp-vulkan` at priority 4;
- `libxcb`, `libglvnd`, `glib`, `zlib`, and the GCC runtime for Docling.

Docling itself is installed with `uv tool install docling` because its nixpkgs
package may be broken. The profile library directory is supplied through
`LD_LIBRARY_PATH` when Docling runs.

The setup leaves an existing CPU `whisper-cpp` profile element intact but gives
the Vulkan element higher precedence. Skill scripts also prepend the user
profile to `PATH`, so a project devenv cannot silently select a CPU build.

## GPU diagnostics

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `loaded CPU backend` only | CPU whisper.cpp build won PATH resolution | Run setup; inspect the binary reported by the doctor. |
| Vulkan library loads but no device appears | `/dev/dri` is hidden or the host driver is unavailable | Rerun with approved host-device access; verify `renderD*`. |
| GPU exists but transcription silently runs on CPU | Direct `whisper-cli` invocation bypassed the guard | Use `scripts/transcribe.sh`; do not call Whisper directly. |
| RADV prints a conformance warning | Mesa RADV identifies itself as non-conformant | Treat the positive device/backend marker as GPU evidence; preserve the log. |
| Docling raises `libxcb.so.1` / `libGL.so` | manylinux wheel cannot see Nix libraries | Run with the user profile `lib` directory in `LD_LIBRARY_PATH`. |
| `ggml-*.bin` is missing | Model setup was skipped | Run setup; use `--large-model` only when needed. |
| Docling `import torchvision` raises `RuntimeError: operator torchvision::nms does not exist` | torch and torchvision were reinstalled at mismatched versions/backends (e.g. ROCm torch + CUDA-build torchvision) | Reinstall torchvision at the exact version matching torch's build tag, from the same wheel index. |
| `DOCLING_DEVICE=cuda` raises `CUDA is not available` on an AMD box | ROCm runtime libraries missing from `LD_LIBRARY_PATH`, or torch is still the CUDA (not ROCm) build | Confirm `rocminfo` sees the card, confirm `~/.nix-profile/lib` is on `LD_LIBRARY_PATH`, confirm `python -c "import torch; print(torch.__version__)"` reports a `+rocmX.Y` suffix — see "Docling GPU acceleration" in SKILL.md. |

## Models

Models live in `${WHISPER_MODEL_DIR:-$HOME/.cache/whisper}`.

- `ggml-small.en-tdrz.bin` (~490 MB) is installed by default for English
  speaker-turn transcription.
- `ggml-large-v3.bin` (~3 GB) is downloaded only with `--large-model`.

Downloads use a temporary partial file and rename it only after curl succeeds.

## WhisperX

`setup-tools.sh --with-whisperx` installs WhisperX from nixpkgs. Multi-speaker
diarization also needs `HF_TOKEN` or `HUGGINGFACE_TOKEN` and accepted access to
the pyannote diarization models. Do not infer speaker identities from numeric
labels.

## Non-Nix systems

Automatic installation is Nix-only. On other systems, the setup script exits
without changes and prints the required capabilities. Metal-capable macOS and
CUDA-capable Linux builds remain acceptable when the doctor observes a positive
runtime backend marker.
