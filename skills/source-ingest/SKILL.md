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
