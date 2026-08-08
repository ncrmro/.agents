# Final assembly

Merge narration onto each scene, then concatenate. Two flags in this file will
silently corrupt the output; both are called out.

## Order

1. Render every scene at final quality (`./render.sh h`).
2. Measure real durations for video and audio.
3. Mux audio onto each scene individually.
4. Concatenate the muxed scenes.
5. Play the result and listen to the boundaries.

## Measure first

```sh
ffprobe -v error -show_entries format=duration -of csv=p=0 scene01.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 narration/scene01.wav
```

Compare per scene. Audio should be shorter than video by 0–5 seconds. If audio
is longer, fix the **animation** — add `self.wait()` and re-render — rather than
speeding up the voice. Speeding narration is audible; a held frame is not.

## Muxing one scene

```sh
ffmpeg -i scene01.mp4 -i narration/scene01.wav \
  -c:v copy -c:a aac -b:a 192k \
  -map 0:v:0 -map 1:a:0 \
  merged/scene01.mp4
```

**Do not use `-shortest`.** It truncates at the shorter stream and clips the
narration mid-word. Without it, ffmpeg extends to the longer stream and the last
video frame holds — which is the behavior you want.

**Do not pair `tpad` with `-shortest`** either; the same clipping returns.

## Silent scenes

A scene with no narration still needs an audio track, or concatenation will
desynchronize everything after it.

```sh
ffmpeg -i scene03.mp4 -f lavfi -i anullsrc=r=44100:cl=stereo \
  -c:v copy -c:a aac -shortest merged/scene03.mp4
```

`-shortest` is correct *here* and only here: the generated silence is infinite,
so something has to bound it.

## Concatenating

**Use the concat filter, not the concat demuxer.** The file-based demuxer
(`-f concat -safe 0 -i list.txt`) produces audible clicks and glitches at every
scene boundary when the streams were encoded separately.

```sh
ffmpeg -i merged/scene01.mp4 -i merged/scene02.mp4 -i merged/scene03.mp4 \
  -filter_complex "[0:v][0:a][1:v][1:a][2:v][2:a]concat=n=3:v=1:a=1[outv][outa]" \
  -map "[outv]" -map "[outa]" \
  -c:v libx264 -crf 18 -preset medium -c:a aac -b:a 192k \
  final_video.mp4
```

`n=` must equal the number of input files. Run it as a single line — backslash
continuations inside some shells introduce encoding problems in the filter
string.

## Verify

```sh
ffprobe -v error -show_entries format=duration \
  -show_entries stream=codec_type,codec_name -of default=noprint_wrappers=1 \
  final_video.mp4
```

- Duration should be the sum of the muxed scenes, within a second.
- There must be exactly one video and one audio stream.
- Watch the boundaries. Clicks mean the demuxer slipped back in.

## When a scene needed heavy padding

If any scene required more than about three seconds of freeze-frame to cover its
narration, the animation is too short for its script. Prefer re-rendering that
scene with more `self.wait()` over shipping a long frozen frame — a held frame
reads as intentional for two seconds and as a bug for five.
