# FFmpeg edit — Video editing and export with ffmpeg

Read this document when the user wants to cut a video, remove sections, speed up
or slow down footage, stitch clips together, or export a final render for
publication. All video work uses ffmpeg — no other video tools.

## Inspect first

Before editing, read the source's metadata:

```bash
ffprobe -v error -show_format -show_streams <input>          # duration, codecs, resolution
ffprobe -v error -show_chapters -of json <input>             # chapter markers (e.g. from OBS)
```

## Cutting

Prefer stream copy for lossless, instant cuts — but it snaps to keyframes:

```bash
ffmpeg -y -loglevel error -ss 00:01:23 -to 00:04:56 -i in.mkv -c copy clip.mkv
```

Re-encode when the cut must be frame-accurate or a filter is applied:

```bash
ffmpeg -y -loglevel error -ss 00:01:23 -to 00:04:56 -i in.mkv \
  -c:v libx264 -crf 18 -preset fast -c:a aac clip.mp4
```

## Speed changes

Video uses `setpts`, audio uses `atempo`. For N× speed:

```bash
# 4x with audio (atempo max is 2.0 per instance — chain for more)
ffmpeg -y -i clip.mkv -filter_complex \
  "[0:v]setpts=PTS/4[v];[0:a]atempo=2.0,atempo=2.0[a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 18 clip-4x.mp4

# Sped-up screen-capture footage usually doesn't need audio — drop it:
ffmpeg -y -i clip.mkv -vf "setpts=PTS/6" -an clip-6x.mp4

# 0.5x slow motion
ffmpeg -y -i clip.mkv -filter_complex \
  "[0:v]setpts=PTS*2[v];[0:a]atempo=0.5[a]" -map "[v]" -map "[a]" clip-slow.mp4
```

Speed assignment by role (from the demo-video pipeline):

| Speed | Use for |
|-------|---------|
| 0.5x  | Dramatic key moments |
| 1x    | Narration, images, transitions |
| 2x    | Key moments with narration |
| 4x    | Standard body clips |
| 6x    | Long body clips, repetitive actions |
| 8x    | Filler, setup footage |

Hitting a target duration: `output_seconds = sum(clip_duration / speed)`.
If over target, speed up body clips first; if under, slow key moments.
Iterate 1–2 clips at a time until within ~10% of target.

## Concatenation

Same-codec clips — concat demuxer (no re-encode):

```bash
printf "file '%s'\n" clip1.mp4 clip2.mp4 > /tmp/concat.txt
ffmpeg -y -f concat -safe 0 -i /tmp/concat.txt -c copy joined.mp4
```

Mixed codecs/resolutions — use the `concat` filter and re-encode.

## Publication export

Final renders are MP4 (H.264 + AAC), widely compatible, web-optimized:

```bash
ffmpeg -y -loglevel error -i edited.mkv \
  -c:v libx264 -crf 20 -preset slow -pix_fmt yuv420p \
  -c:a aac -b:a 192k -movflags +faststart output/final.mp4
```

- `-pix_fmt yuv420p` — required for playback compatibility (browsers, phones).
- `-movflags +faststart` — moves the moov atom so streaming starts immediately.
- Record/edit in MKV, export MP4 for publication.

After exporting, re-transcribe `final.mp4` (see `transcribe.md`) so subtitles and
chapter metadata match the actual edit.

## Working rules

- Never overwrite the source recording; write results to `output/` or a new
  basename.
- Long renders take minutes — run them as background tasks and verify the
  output (duration via ffprobe, plus a playback spot-check) when they finish.
- Show the user the edit plan (segment timestamps, actions, estimated output
  duration) before rendering the final.
