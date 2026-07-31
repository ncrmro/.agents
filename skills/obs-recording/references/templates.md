# Scene and source manifests

The files in `assets/` are operator manifests, not OBS's internal scene
collection JSON. OBS's saved JSON contains plugin- and platform-specific
settings, device IDs, and PipeWire portal tokens; copying it as a generic
template is brittle and may expose local identifiers.

## Use a template

```bash
SKILL_DIR="${HOME}/.agents/skills/obs-recording"
cp "${SKILL_DIR}/assets/scenes/desktop.json" ./obs-scene.json
# Edit exact scene/source names, dimensions, FPS, and expectations.
"${SKILL_DIR}/scripts/obsctl.mjs" doctor --manifest ./obs-scene.json
```

The doctor compares the manifest with live OBS state. It does not create or
change scenes, sources, devices, or portal grants. `desktop.json` and
`talking-head.json` are 3840×2160 at 60 FPS and use the source names discovered
on the originating Linux workstation; they MUST be customized when the target
OBS instance differs.

## Schema

```json
{
  "version": 1,
  "scene": { "name": "Exact scene name" },
  "video": {
    "baseWidth": 1920,
    "baseHeight": 1080,
    "outputWidth": 1920,
    "outputHeight": 1080,
    "fps": 30
  },
  "sources": [
    {
      "name": "Exact source name",
      "role": "screen",
      "required": true,
      "visible": true,
      "kinds": ["pipewire-screen-capture-source"]
    }
  ],
  "audioInputs": [
    {
      "name": "Mic/Aux",
      "role": "microphone",
      "required": true,
      "muted": false,
      "minGainDb": -60
    }
  ],
  "recording": {
    "minFreeGiB": 20,
    "preferredContainers": ["hybrid_mp4", "mkv"]
  }
}
```

`role`, `preferredContainers`, and unknown fields document operator intent.
Current validation enforces scene presence, source name/kind/visibility, audio
name/mute state/minimum fader gain, video dimensions/FPS, and minimum free
space. Fader gain is configuration, not proof of live signal; verify meters or
the recorded media separately.

## Platform source kinds

Discover exact kinds from live OBS with `obsctl.mjs sources --json` and
`obsctl.mjs audio --json`.

| Role | Common Linux kinds | Other common kinds |
| --- | --- | --- |
| Screen/window | `pipewire-screen-capture-source`, `xshm_input` | `monitor_capture`, `window_capture`, `screen_capture` |
| Camera | `pipewire-camera-source`, `v4l2_input` | `dshow_input`, `av_capture_input` |
| Desktop audio | `pulse_output_capture`, PipeWire audio plugin kinds | `wasapi_output_capture`, `coreaudio_output_capture` |
| Microphone | `pulse_input_capture`, PipeWire audio plugin kinds | `wasapi_input_capture`, `coreaudio_input_capture` |

Names and kinds are case-sensitive. Always discover them from the target OBS
instance rather than normalizing or guessing.

## Circular camera overlays

Use `assets/masks/circle-480.png` as a centered alpha-mask template. Keep the
mask used by a live scene at a stable path; OBS stores that path in the filter
settings.

1. Capture the raw camera source and choose a square region around the subject.
2. Add a `mask_filter_v2` filter with type `mask_alpha_filter.effect`.
3. If the subject is not centered in the source, generate a source-sized mask
   with the circle centered on the subject. Do not stretch a square mask across
   a widescreen source.
4. Crop the scene item to the same square region, then scale and position it.
5. Read back the filter and transform, capture the Program scene, and run
   `doctor`. A successful request alone does not prove the composition is
   correct.

The mask filter runs on the source before the scene-item crop. A mask and crop
that select different regions can produce empty or off-center output.
