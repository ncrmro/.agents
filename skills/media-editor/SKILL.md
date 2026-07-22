---
name: media-editor
description: Plan and execute transcript-driven media work — transcribe audio/video (with multi-speaker diarization), then cut, speed-adjust, subtitle, and export publication-ready MP4s. Use for raw recordings, meetings, or footage that needs transcription, speaker attribution, cuts, or a final render.
---

# Media Editor

Use this skill to turn a raw recording into a concise, publication-ready video,
or an audio/video file into an accurate (optionally speaker-labeled) transcript.
Transcript timestamps drive cut and speed decisions.

Supporting documents live next to this `SKILL.md`; read them only when needed:

- `setup-tools.md` — install/verify the toolchain via `scripts/deps-doctor.sh`
  or the bundled `devenv.nix`.
- `transcribe.md` — single-track transcription (whisper.cpp) and multi-speaker
  diarization (whisperx), plus optional LLM transcript post-processing.
- `ffmpeg-edit.md` — cut, speed-adjust, concatenate, and export final media.

## Toolchain

- `ffprobe` for source inspection: duration, streams, chapters, codecs, resolution.
- `ffmpeg` for all video work: extraction, cutting, speed changes, concatenation,
  encoding, and final export. Do not use other video tools unless the user asks.
- `whisper.cpp` (`whisper-cli`) for fast local single-track speech-to-text;
  `whisper-cpp-vulkan` is GPU-accelerated where Vulkan drivers exist.
- `whisperx` for **multi-speaker diarization** (real `SPEAKER_NN` labels + word
  timestamps) when a recording has more than one voice.
- *(optional)* a local **Ollama** LLM (e.g. `nemotron-3-nano`) for transcript
  post-processing — speaker naming, cleanup, summaries. It does **not** transcribe.

### Setup

If a required tool is missing, run `scripts/deps-doctor.sh` (report) or
`scripts/deps-doctor.sh --install` (fix), or enter the bundled `devenv shell`.
See `setup-tools.md`. Ask before downloading large whisper models. Diarization
needs an `HF_TOKEN` with the pyannote terms accepted.

## Standard pipeline

1. **Inspect** — run `ffprobe` on the source recording before editing.
2. **Transcribe** — follow `transcribe.md` and its "Order of operations":
   whisper-cli first (GPU on AMD; single-speaker, subtitles, edit planning),
   escalating to whisperx `--diarize` only when you need speaker labels — with
   `--min_speakers/--max_speakers` when the count is known.
3. **Plan the edit** — read the transcript and identify content boundaries: dead
   air, filler, retakes, mistakes, key moments. Build a timestamped edit plan
   with segment ranges, actions, speeds, and estimated output length.
4. **Confirm the plan** — show the user the segment table and estimated final
   duration before rendering.
5. **Edit** — follow `ffmpeg-edit.md` to cut, speed-adjust, and concatenate.
6. **Export** — MP4 for publication: H.264, AAC, yuv420p, `+faststart`.
7. **Verify** — compare output duration to the plan, spot-check playback, and
   re-transcribe the final render when subtitles or chapter timing matter.

## Speed planning

Assign speeds by role, then estimate duration as:

```text
output_seconds = sum(segment_duration / speed)
```

| Speed | Use for |
|-------|---------|
| 1x    | narration, explanations, transitions, important details |
| 2x    | key moments that can move faster while preserving comprehension |
| 4x–6x | process/body footage, repetitive screen work, assembly steps |
| 6x–8x | filler, setup, waiting, low-information movement |

Iterate until the estimate is within ~10% of the user's target. If over target,
speed up body clips first; if under, slow down key moments before padding filler.

## Working discipline

- Never overwrite source recordings. Write derived WAV/SRT/JSON/clips/finals
  alongside the input or under `output/` with the same basename.
- Run long `whisper-cli`, `whisperx`, and `ffmpeg` jobs in the background and
  check results when complete.
- Prefer stream copy (`-c copy`) for lossless cuts when keyframe alignment is
  acceptable; re-encode only for frame-accurate cuts or filters.
- Treat the transcript as the source of truth for edit decisions; cite transcript
  timestamps when proposing cuts. Keep any LLM post-processed transcript as a
  derived, reviewable artifact — never as a replacement for the raw one.
- Keep intermediate and final filenames descriptive enough to recover the edit
  path without chat history.

## Minimal command shape

```bash
# inspect
ffprobe -v error -show_format -show_streams input.mkv

# transcript via helper document
# read transcribe.md, then transcribe input.mkv (whisper.cpp or whisperx --diarize)

# edit via helper document after the user approves the plan
# read ffmpeg-edit.md, then render the approved plan
```
