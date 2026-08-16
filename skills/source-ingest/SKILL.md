---
name: source-ingest
description: Convert source artifacts into searchable text with GPU-first whisper.cpp transcription, speaker-turn diarization, and Docling PDF extraction. Use when ingesting a recording, meeting, paper, statement, or media file.
---

# Source ingest

Turn original source artifacts into searchable representations. The original
artifact is canonical and must never be modified; generated transcripts and OCR
may be corrected only where the source meaning is unambiguous.

Supporting files:

- `scripts/setup-tools.sh` — install the Nix-profile toolchain and default model.
- `scripts/toolchain-doctor.sh` — prove which transcription backend is active.
- `scripts/transcribe.sh` — extract audio and produce raw TXT/SRT/JSON with a
  preserved runtime log.
- `environment-dependencies.md` — platform details and diagnostics.

## GPU-first rule

**Never start a long transcription until a runtime probe positively identifies
Vulkan, CUDA, or Metal.** The presence of `whisper-cli` does not prove GPU use.
The bundled transcription wrapper fails closed on CPU unless the user explicitly
authorizes `--allow-cpu`.

Run the doctor first:

```bash
~/.agents/skills/source-ingest/scripts/toolchain-doctor.sh
```

If dependencies are missing, install them into the user Nix profile rather than
editing the current project's devenv:

```bash
~/.agents/skills/source-ingest/scripts/setup-tools.sh
```

The setup installs the Vulkan whisper.cpp build at a higher profile priority
than a CPU build, installs the default English tinydiarize model, and verifies
the result. If a sandbox hides `/dev/dri`, rerun setup, the doctor, and
transcription with approved host-device access; do not accept the resulting CPU
fallback.

## Transcribing audio or video

Use the wrapper rather than calling `whisper-cli` directly:

```bash
~/.agents/skills/source-ingest/scripts/transcribe.sh <source-media> \
  --output-base <scratch>/transcript \
  --tinydiarize
```

The wrapper:

1. selects the user-profile Vulkan build ahead of project-local tools;
2. extracts disposable 16 kHz mono WAV audio;
3. refuses CPU unless `--allow-cpu` was explicit;
4. writes raw TXT, SRT, JSON, a Whisper runtime log, and backend metadata; and
5. refuses to overwrite existing output artifacts.

Use `--tinydiarize` for two-speaker English recordings. The model detects
speaker turns, not identities. For more than two speakers or higher-fidelity
attribution, install WhisperX with `setup-tools.sh --with-whisperx`; it still
requires a Hugging Face token and accepted pyannote model terms. Identify
speakers by name only when the user or the source confirms them.

Verify that each SRT starts near `00:00:00`, spans the full source duration
reported by `ffprobe`, and survives audio spot-checks. Convert raw output into
the consuming project's readable transcript format while retaining reasonable
timestamps.

For accuracy-critical single-speaker material, install the large model
explicitly:

```bash
~/.agents/skills/source-ingest/scripts/setup-tools.sh --large-model
```

Then pass it with `transcribe.sh --model
~/.cache/whisper/ggml-large-v3.bin`.

## Converting PDFs to Markdown

Run Docling with the user-profile runtime libraries:

```bash
LD_LIBRARY_PATH="$HOME/.nix-profile/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH" \
  docling <source.pdf> --to md --output <output-directory> \
  --image-export-mode placeholder
```

Docling names the generated file after the PDF. Rename it to the destination
required by the consuming project.

1. Verify dates, totals, section structure, tables, and OCR against the PDF.
2. Correct obvious extraction errors only where the source is unambiguous.
3. Keep the original PDF canonical and untouched.
4. Default to `placeholder`; use referenced figures only when they matter.

The first conversion downloads layout/OCR models and may take several minutes.

## Docling GPU acceleration

**Never run a large Docling batch until a runtime probe positively proves
`torch.cuda.is_available()` is `True`.** Docling has no CLI device flag;
device selection is the `DOCLING_DEVICE` environment variable (`auto`, `cpu`,
`cuda`, `cuda:N`, `mps`, `xpu`). Setting `DOCLING_DEVICE=cuda` fails closed —
Docling raises instead of silently falling back to CPU — so prefer it over
`auto` once GPU is proven.

### Managed-sandbox visibility gate

**Do not treat a failed probe inside a managed sandbox as a broken ROCm
installation.** A sandbox can hide `/dev/kfd` and `/dev/dri` while the host GPU,
user groups, ROCm runtime, and PyTorch wheels are all correct. This failure
looks like `torch.cuda.is_available() == False` and `device_count() == 0`.

Check device visibility before you reinstall or replace anything:

```bash
ls -ld /dev/kfd /dev/dri 2>/dev/null
rocminfo 2>&1 | head -20
```

- If `/dev/kfd` and `/dev/dri` are absent, rerun the positive PyTorch probe
  with approved host-device access. Do not reinstall ROCm or PyTorch first.
- If the host probe succeeds, run every Docling command that needs the GPU
  with the same host-device access and `DOCLING_DEVICE=cuda`.
- If the host probe fails while the device nodes are visible, continue with
  the ROCm version, wheel, and ABI checks below.
- Use the CPU fallback only after the host-access probe fails. Hidden device
  nodes alone do not justify a CPU fallback.

Verified working on this machine: AMD Radeon RX 9070 XT (RDNA4, gfx1201, ROCm
7.2.3). ROCm-built PyTorch exposes AMD GPUs through the same `torch.cuda` API
CUDA uses (HIP aliases as CUDA for compatibility), so `DOCLING_DEVICE=cuda`
also selects the ROCm-backed AMD GPU — this is expected, not a bug.

### Recipe (ROCm / AMD, RDNA4)

1. Install `rocminfo`/`rocm-smi` into the user Nix profile (never a project
   devenv — same rule as the whisper.cpp Vulkan build) to preflight-check the
   card before touching Docling:

   ```bash
   nix profile add nixpkgs#rocmPackages.clr nixpkgs#rocmPackages.rocm-smi
   ```

   ```bash
   rocm-smi          # lists the device
   rocminfo | grep -E "Name:|Marketing"   # look for gfx1201 / your gpuTargets code
   ```

   ROCm 7.2 added native gfx1200/gfx1201 (RDNA4) support — no
   `HSA_OVERRIDE_GFX_VERSION` workaround needed on this generation. If
   `rocminfo` doesn't list the GPU, the card is unsupported by the installed
   ROCm version; do not proceed to the pip step until it does.

   The PyTorch ROCm wheel (step 2) vendors its own ROCm runtime libraries
   inside `torch/lib` — that's most of its multi-GB size. Once it's
   installed, `torch.cuda.is_available()` works without `LD_LIBRARY_PATH`
   pointing at the Nix profile at all; a wider `rocmPackages.*` install
   (hipblas, miopen, rocblas, rocfft, rccl, …) is not load-bearing for
   Docling and was not needed here. Install those extra packages only if a
   specific missing-library error names one.

2. Replace Docling's CUDA-build torch/torchvision with the matching ROCm
   wheels, in its `uv tool` venv. Pin the ROCm minor version pytorch.org
   publishes closest to `rocmPackages.clr.version` (check with `nix eval
   nixpkgs#rocmPackages.clr.version`); match the torch/torchvision version
   pair exactly, or `import torchvision` raises `RuntimeError: operator
   torchvision::nms does not exist` (ABI mismatch, not a ROCm problem):

   ```bash
   uv pip install --python ~/.local/share/uv/tools/docling/bin/python \
     "torch==2.13.0+rocm7.2" "torchvision==0.28.0+rocm7.2" \
     --index-url https://download.pytorch.org/whl/rocm7.2
   ```

3. Run Docling with the Nix profile libraries on `LD_LIBRARY_PATH` — still
   needed for Docling's own `libxcb`/`libGL` dependencies, same as the CPU
   recipe above, even though the ROCm wheel no longer needs it — and
   `DOCLING_DEVICE=cuda` so a broken GPU path fails loudly instead of
   silently falling back to CPU:

   ```bash
   LD_LIBRARY_PATH="$HOME/.nix-profile/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
     PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH" \
     DOCLING_DEVICE=cuda \
     docling <source.pdf> --to md --output <output-directory> \
     --image-export-mode placeholder --verbose
   ```

4. Verify with a positive probe before trusting any conversion — don't trust
   silent success. `LD_LIBRARY_PATH` is not required for this probe (the
   ROCm wheel is self-contained), but is harmless to include for parity with
   the actual Docling invocation:

   ```bash
   ~/.local/share/uv/tools/docling/bin/python -c "
   import torch
   assert torch.cuda.is_available()
   print(torch.cuda.get_device_name(0), torch.cuda.get_device_properties(0).gcnArchName)"
   ```

   Expect `AMD Radeon Graphics gfx1201` (torch reports the generic marketing
   string for ROCm cards; `gcnArchName` is the field that actually identifies
   the silicon). In the `--verbose` conversion log, confirm
   `docling.utils.accelerator_utils: Accelerator device: 'cuda:0'` and
   RapidOCR's `Using GPU device with ID: 0` — both appear per-model-load, so
   look for them near the top of the run, not just once.

Fallback: if the ROCm wheel install or a **host-access** probe does not produce
a positive result, set `DOCLING_DEVICE=cpu` (or unset it). The ROCm torch build
runs fine on CPU too — no need to reinstall the CUDA-build torch — so CPU-only
remains the prior working state and an acceptable outcome.

## Wiki handoff

When the destination is a durable wiki, also use its `wiki` skill. The wiki
workflow owns source-note frontmatter, provenance, tags, links, indexes, change
logs, and reconciliation of durable concepts or problems. A transcript or OCR
file alone is not a completed wiki ingest.

## Validation

- The original artifact is unchanged.
- Runtime metadata names a verified GPU backend unless CPU was explicitly
  authorized.
- Raw output spans the source duration and is spot-checked.
- Extracted text does not introduce claims absent from the source.
- Executable scripts pass `tests/source-ingest.test.sh`.
