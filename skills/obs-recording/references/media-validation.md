# Recorded audio validation and transcription

Use `scripts/recording-check.mjs` after OBS returns the stopped recording path.
Do not infer the path from directory order when several files were created close
together; inspect each candidate or use the path returned by `StopRecord`.

## Validate

```bash
SKILL_DIR="${HOME}/.agents/skills/obs-recording"
"${SKILL_DIR}/scripts/recording-check.mjs" "/path/to/recording.mkv"
```

The command uses `ffprobe` and `ffmpeg` without rewriting the media. It reports
every selected audio stream with:

- mean and maximum dBFS;
- integrated LUFS and loudness range;
- true peak;
- silence intervals lasting at least 0.2 seconds below -50 dBFS;
- warnings for silence, likely clipping, or very quiet spoken audio.

Interpret short test clips cautiously: integrated LUFS is less stable over a few
seconds than over a complete recording. For spoken-word setup, use these as
references rather than universal pass conditions:

- keep true peak below -1 dBFS;
- peaks around -12 to -6 dBFS usually leave useful headroom;
- integrated loudness around -24 to -16 LUFS is a common working range, but the
  delivery platform sets the final target.

If the recording is quiet, correct the OBS input gain or filter chain and make a
new fixture. Do not normalize the test file and claim that capture is fixed.

## Transcribe

For a recording with one selected audio stream:

```bash
"${SKILL_DIR}/scripts/recording-check.mjs" \
  "/path/to/recording.mkv" --transcribe
```

The checker delegates to media-editor's shared command. That command extracts a
temporary 16 kHz mono WAV, runs a short model-load probe, and classifies GPU only
when configured log markers identify Vulkan, Metal, or CUDA. Successful JSON
reports include the backend, parsed device label, CPU fallback reason,
diarization decision, and raw whisper.cpp artifact paths. The command preserves
the raw log, never downloads a model, and never overwrites existing artifacts.

Use `--diarize auto|always|never`. In auto mode, WhisperX runs only when stream
metadata indicates multiple speakers and both WhisperX and `HF_TOKEN` are
available. Otherwise, the report explains why it skipped diarization and how to
force it. `always` requires WhisperX; `never` disables it. The command does not
infer speaker count. With `--require-gpu`, a CPU classification exits before
transcription, writes the reason to stderr, and produces no final JSON report.

When the file has multiple audio streams, select one explicitly:

```bash
"${SKILL_DIR}/scripts/recording-check.mjs" recording.mkv \
  --audio-stream 2 --transcribe
```

Whisper.cpp raw timestamped output is always retained. When labels are selected,
WhisperX runs afterward and its raw `.diarized.*` outputs remain separate from
any cleaned or summarized transcript.
