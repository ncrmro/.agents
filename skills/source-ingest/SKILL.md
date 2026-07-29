---
name: source-ingest
description: Convert source artifacts into searchable text—transcribe audio/video with whisper.cpp and convert PDFs to Markdown with Docling. Use when ingesting a recording, meeting, paper, statement, or media file.
---

# Source ingest

Turn original source artifacts into searchable representations. The original
artifact is canonical and must never be modified; generated transcripts and OCR
may be corrected only where the source meaning is unambiguous.

## Tool check

Run the checks needed for the artifact being imported:

```bash
docling --version >/dev/null 2>&1 || echo "missing: docling"
ffmpeg -version >/dev/null 2>&1 || echo "missing: ffmpeg"
ffprobe -version >/dev/null 2>&1 || echo "missing: ffprobe"
whisper-cli --help >/dev/null 2>&1 || echo "missing: whisper-cli"
```

If a tool is missing or errors at runtime, read
`environment-dependencies.md` before improvising. On NixOS, prefer the
project's reproducible devenv and run tools with `devenv shell --`.

## Converting PDFs to Markdown with Docling

```bash
docling <source.pdf> --to md --output <output-directory> --image-export-mode placeholder
```

Docling names the generated file after the PDF. Rename it to the destination
required by the consuming agent or project.

1. Verify the Markdown against the PDF: check dates and totals, section
   structure, tables, and any OCR output.
2. Correct obvious extraction errors only where the source is unambiguous.
3. Keep the original PDF canonical and untouched.
4. Default to `--image-export-mode placeholder`; use `referenced` only when
   extracted figures matter.

The first conversion can download models and take several minutes, so run it as
a background task when appropriate.

## Transcribing audio or video

1. Extract 16 kHz mono WAV into a scratch directory:

   ```bash
   ffmpeg -y -loglevel error -i <source> -vn -ar 16000 -ac 1 <scratch>/audio.wav
   ```

2. Transcribe with an appropriate local Whisper model:

   ```bash
   whisper-cli -m ~/.cache/whisper/ggml-large-v3.bin \
     -f <scratch>/audio.wav --output-srt --output-json \
     --output-file <scratch>/transcript
   ```

3. Verify that the transcript spans the full source duration and spot-check it
   against the recording.
4. Keep raw SRT or JSON alongside the Markdown transcript when useful.

Use the tinydiarize model and `--tinydiarize` for two-speaker English recordings
when speaker turns are needed. Treat detected turns as fallible and identify
speakers by name only when the user confirms them.
