# Transcribe — Timestamped transcription with whisper.cpp (+ diarization)

Read this document when the user asks to transcribe a video or audio file, wants
subtitles, needs timestamped text to find cut points, or wants a **multi-speaker**
conversation split by who is talking.

Two engines, picked by the job:

- **whisper.cpp (`whisper-cli`)** — fast local single-track transcription with
  SRT/JSON timestamps. Default for narration, screen recordings, and edit
  planning.
- **whisperx** — faster-whisper ASR + wav2vec2 word alignment + **pyannote
  speaker diarization**. Use when the recording has multiple speakers and you
  need real `SPEAKER_NN` labels, not just a single transcript.

If a tool is missing, run `scripts/deps-doctor.sh` (see `setup-tools.md`).

## Order of operations

Try things in this order — stop as soon as the result is good enough:

1. **Preflight** — `scripts/deps-doctor.sh`. For diarization, confirm `HF_TOKEN`
   is set *and* the gated pyannote models are accepted (`README.md` → gated
   models), or `--diarize` fails with a 403.
2. **Transcribe with `whisper-cli` first** — it's GPU-accelerated on AMD via
   Vulkan and is all you need for single-speaker audio, subtitles, and edit
   planning. `ggml-large-v3` for accuracy, `base.en`/`small.en` for speed.
3. **Escalate to `whisperx --diarize` only when you need speaker labels** (runs
   on CPU here). Climb this ladder, stopping when attribution is right:
   1. `whisperx <audio> --model small --diarize --hf_token "$HF_TOKEN"`.
   2. Speakers collapsing into one `SPEAKER_00`? Add
      `--min_speakers N --max_speakers N` when the count is known — **essential**
      for close-mic'd voices recorded on one device.
   3. Still rough? Raise `--model` (small → medium → large-v3) for better
      embeddings and attribution.
4. **Optional LLM post-pass** — send the diarized transcript to Ollama/nemotron
   to name `SPEAKER_NN` from context, fix ASR typos, or summarize.

## Requirements

- `ffmpeg` on PATH (audio extraction).
- `whisper-cli` (whisper.cpp) and a whisper model. Prefer the large model at
  `$WHISPER_MODEL_DIR/ggml-large-v3.bin` (`WHISPER_MODEL_DIR` defaults to
  `~/.cache/whisper`). `ggml-base.en.bin` is an acceptable fast English fallback;
  `ggml-small.en-tdrz.bin` adds weak two-speaker turn markers.
- For diarization: `whisperx` plus a Hugging Face token (`HF_TOKEN`) with the
  pyannote model terms accepted.

## Single-track transcription (whisper.cpp)

1. Extract the audio as 16 kHz mono WAV — what whisper.cpp expects:

   ```bash
   ffmpeg -y -loglevel error -i <input.(mp4|mkv|mov|m4a)> -vn -ar 16000 -ac 1 <basename>.wav
   ```

2. Transcribe with timestamped output. Run as a **background task** — expect
   minutes of wall time per few minutes of audio:

   ```bash
   whisper-cli -m "$WHISPER_MODEL_DIR/ggml-large-v3.bin" -f <basename>.wav \
     --output-srt --output-json --output-file <basename>
   ```

3. Verify `<basename>.srt` exists, timestamps start at `00:00:00` and span the
   full media duration (compare `ffprobe -show_format`), and spot-check a few
   segments against the audio.

`whisper-cpp-vulkan` uses the GPU automatically when Vulkan drivers are present;
otherwise it runs on CPU. No flags needed.

## Multi-speaker diarization (whisperx)

`whisper-cli --tinydiarize` only marks speaker *turns* for two English speakers
and is unreliable — for real speaker attribution use whisperx:

```bash
whisperx <input> \
  --model large-v3 \
  --diarize \
  --hf_token "$HF_TOKEN" \
  --output_format srt --output_format json \
  --output_dir <dir>
```

- Output SRT/JSON carry `SPEAKER_00`, `SPEAKER_01`, … plus word-level timestamps.
- `--min_speakers` / `--max_speakers` help when the count is known — and often
  are **necessary**: auto-clustering tends to under-segment close-mic'd voices
  recorded on one device (they collapse into a single `SPEAKER_00`). If you know
  it's two people, pass `--min_speakers 2 --max_speakers 2`. A larger `--model`
  (e.g. `small`+) also improves separation.
- On this class of machine whisperx runs its torch models on **CPU** (GPU torch
  is out of scope), so it is slower than `whisper-cli` — reach for it only when
  diarization is actually needed.
- Diarization requires `HF_TOKEN` **and** an account that has accepted the gated
  pyannote model terms — a token alone yields a `GatedRepoError 403`. whisperx's
  default `--diarize_model` is `pyannote/speaker-diarization-community-1`; pass
  `--diarize_model pyannote/speaker-diarization-3.1` to use 3.1 instead (accept
  it and its `pyannote/segmentation-3.0` dependency). See `README.md` → "gated
  models". On AMD, whisperx runs on CPU (see `README.md` → GPU notes).

### Writing `transcript.md`

Split the text at speaker changes and label turns. Prefer whisperx's
`SPEAKER_NN` labels; with tinydiarize, split on `[SPEAKER_TURN]` and assign
`**Speaker A:**` / `**Speaker B:**` yourself, keeping the assignment consistent.
Keep timestamps at reasonable intervals. Only name speakers when the user
confirms who is who. Keep the raw SRT/JSON alongside as `.srt` / `.json`.

## Optional: LLM post-processing (Ollama / nemotron)

A local text LLM can clean up a diarized transcript — **it does not transcribe**.
Point at any Ollama endpoint via `OLLAMA_HOST` (default `http://localhost:11434`)
and any pulled model via `NEMOTRON_MODEL` (default `nemotron-3-nano`). Uses:

- attribute `SPEAKER_NN` labels to real names from context;
- fix obvious ASR errors without changing meaning;
- produce a summary or a segmented edit plan.

```bash
curl -s "${OLLAMA_HOST:-http://localhost:11434}/api/chat" -d @- <<JSON | jq -r '.message.content'
{
  "model": "${NEMOTRON_MODEL:-nemotron-3-nano}",
  "stream": false,
  "messages": [
    {"role": "system", "content": "You clean up diarized transcripts. Keep meaning; do not invent content."},
    {"role": "user", "content": "Rename SPEAKER_00/01 from context and fix ASR typos:\n\n<paste transcript>"}
  ]
}
JSON
```

Always keep the raw transcript; treat the LLM pass as a derived, reviewable
artifact.

## Output

Standard SRT with sequential timestamped segments (diarized output prefixes the
speaker):

```
1
00:00:00,000 --> 00:00:05,200
[SPEAKER_00] You can see this is something we pulled out of the ground

2
00:00:05,200 --> 00:00:10,800
[SPEAKER_01] and it's basically just clay
```

## Conventions

- Transcripts keep the media basename with `.srt` / `.json` alongside it.
- The intermediate WAV is disposable — write it to a scratch dir; don't commit it
  unless the project tracks WAVs in LFS.
- SRT is for humans and edit planning; JSON carries per-segment/word timestamps
  for programmatic use.
