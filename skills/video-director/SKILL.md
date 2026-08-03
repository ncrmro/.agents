---
name: video-director
description: Plan, capture, narrate, synchronize, and edit agent-driven software demo videos from live terminal, browser, and desktop sources. Use when making a CLI walkthrough, web product demo, desktop application demo, or one video that combines several live sources. Supports local Piper narration and ElevenLabs narration.
compatibility: Requires capture tools for the selected sources. Terminal capture uses asciinema. Browser and desktop capture use OBS. Narration uses Piper or ElevenLabs. Browser control uses an available browser automation tool.
metadata:
  status: experimental
  inspired-by: https://github.com/nebrass/hve-video-director
---

# Video director

Create a software demo from real product interactions. Treat `terminal`,
`browser`, and `desktop` as capture sources. Do not treat them as exclusive
video types.

Supporting documents:

- `references/capture-sources.md` — read before capture.
- `references/narration.md` — read when a video uses spoken narration.
- `references/production-manifest.md` — read when you create or change a
  production manifest.
- `assets/production.example.yml` — copy as the initial production manifest.

Use these companion skills when they are available:

- `browser-mcp` controls a browser.
- `obs-recording` controls and checks OBS.
- `media-editor` plans edits and renders the final video.

## Default model

A video contains scenes. A scene contains one or more live sources.

```text
video
└── scenes
    ├── terminal
    ├── browser
    ├── desktop
    ├── terminal + browser
    └── browser + desktop + terminal
```

Each scene MUST be a recoverable take. Each source MUST keep its raw artifact.
The editor MAY show one source, split the frame, use picture-in-picture, or cut
between sources.

## Workflow

1. Define the audience, claim, target duration, and output format.
2. Decide if the video uses narration. Select Piper or ElevenLabs.
3. Divide the story into scenes. Give each scene one purpose.
4. Select the live sources for each scene.
5. Inspect the capture tools. Read the applicable companion skills.
6. Copy `assets/production.example.yml` into the production directory.
7. Record every action, expected result, side effect, and artifact in the
   manifest.
8. Prepare isolated demo state. Use seed data and disposable workspaces when
   possible.
9. Rehearse the complete action sequence without recording.
10. Show the user the storyboard, side effects, secret risks, and capture
   layout before a consequential recording.
11. Capture one scene at a time. Retry only the failed scene.
12. Check each raw artifact immediately after capture.
13. Write one narration sentence on each non-empty script line.
14. Use `scripts/render-narration.sh` to create the narration WAV.
15. Build a timestamped edit plan. Get approval before the final render.
16. Use `media-editor` for cuts, subtitles, audio, and export.
17. Check the final video against the manifest and the product claim.

## Concurrent live sources

Use concurrent capture when actions in one source change another source.
Examples include a terminal deployment that updates a browser or a browser
action that changes a desktop client.

1. Start each recorder.
2. Check that each recorder is active.
3. Write one shared synchronization marker to the event log.
4. Run the approved action sequence.
5. Check each expected product state.
6. Stop each recorder.
7. Record every returned artifact path in the manifest.

Record sources separately when the tools support it. A default OBS recording
does not create one file per OBS source. Use separate recorders or a verified
source-recording setup when the edit needs independent browser and desktop
tracks. Otherwise, compose those sources in OBS during capture.

## Production bundle

Use this portable layout:

```text
demo/
├── production.yml
├── events.ndjson
├── raw/
│   └── narration.txt
├── derived/
│   └── narration.wav
├── edit-plan.md
└── output/
    ├── demo.mp4
    └── demo.srt
```

Treat files in `raw/` as immutable. Put conversions and repaired media in
`derived/`.

## Safety

- The action plan MUST name each command and product action before capture.
- The agent MUST identify external writes and destructive actions.
- The agent MUST record the narration provider in `production.yml`.
- The agent MUST get user approval before an ElevenLabs request.
- The agent MUST NOT put an ElevenLabs API key in a command, manifest, log, or
  artifact.
- The agent MUST NOT silently change the narration provider.
- The agent MUST NOT expose credentials, tokens, private messages, unrelated
  browser tabs, shell history, notifications, or secret environment values.
- Browser capture SHOULD use an isolated profile.
- Desktop capture SHOULD use a dedicated workspace with only the required
  windows.
- Terminal capture SHOULD use a disposable worktree or sandbox.
- The agent MUST follow the `obs-recording` safety rules for all OBS writes.
- The agent MUST NOT overwrite or delete raw recordings.
- The agent MUST stop if it cannot verify the capture boundary or hide secret
  data.

## Validation

- The manifest MUST list every scene and source.
- Every action MUST have an expected result.
- Every source MUST produce a raw artifact that opens or replays.
- A narrated video MUST have a non-silent audio stream.
- A narrated video MUST have a transcript that matches the narration script.
- The manifest MUST identify Piper or ElevenLabs when narration exists.
- Concurrent sources MUST have a synchronization method.
- The final render MUST match the requested frame size, frame rate, duration,
  and container.
- The final render MUST NOT contain secret or unrelated information.
- The final product state MUST support the claim made by the demo.

## Diagnostics

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Terminal source is unavailable | `asciinema` is not on `PATH` | Stop and report the missing dependency. |
| Terminal conversion is unavailable | `agg` is not on `PATH` | Keep the cast file. Report that pixel conversion is unavailable. |
| Browser actions work but no window is visible | The browser tool started a headless browser | Read `browser-mcp` and configure a headful or attached browser. |
| OBS records the wrong content | The active scene or source boundary is wrong | Stop recording. Read `obs-recording`. Check the scene and visible sources. |
| Piper is unavailable | `piper` is not on `PATH` | Install `nixpkgs#piper-tts`. Do not use ElevenLabs as a fallback. |
| Piper omits sentences | The script has multiple sentences on one line | Put one sentence on each non-empty line. Render the narration again. |
| ElevenLabs refuses the request | The key, voice, model, quota, or request approval is missing | Check the API response and configuration. Do not use Piper as a fallback. |
| Narration is silent | The provider response is not valid audio, or the mix maps the wrong stream | Check the WAV with `ffprobe`. Check the final audio map. |
| Sources drift during the edit | The sources do not share a useful marker | Add a visible or logged marker and record the scene again. |
| Browser and desktop are in one file | OBS captured a composed scene | Use separate recorders or accept the composed source. |
| A scene has many failed actions | The demo state is not deterministic | Reset the state. Improve the rehearsal and expected-state checks. |

## Origin

This experimental skill was informed by
[`hve-video-director`](https://github.com/nebrass/hve-video-director). It uses
an Outfitter-native structure and composes the existing personal skills.
