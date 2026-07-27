# Safe recording operations

## Command surface

Run the bundled CLI directly:

```bash
SKILL_DIR="${HOME}/.agents/skills/obs-recording"
"${SKILL_DIR}/scripts/obsctl.mjs" doctor
"${SKILL_DIR}/scripts/obsctl.mjs" status
"${SKILL_DIR}/scripts/obsctl.mjs" scenes
"${SKILL_DIR}/scripts/obsctl.mjs" sources
"${SKILL_DIR}/scripts/obsctl.mjs" audio
"${SKILL_DIR}/scripts/obsctl.mjs" meters --seconds 3
```

The script uses `OBS_WEBSOCKET_PASSWORD` when set. Otherwise it reads the
same-user OBS config at
`~/.config/obs-studio/plugin_config/obs-websocket/config.json`. It never prints
the password.

## Safety contract

1. Inspect `doctor` and `status` before changing state.
2. Use explicit verbs. Never replace `start`/`stop` or `pause`/`resume` with a
   toggle because retries can invert state.
3. Do not change scene collections, profiles, encoders, paths, or source
   settings while recording.
4. Treat starting, stopping, splitting, chapter creation, screenshot writes,
   source changes, and audio changes as writes.
5. Before `start`, verify the intended scene, required sources, audio mute and
   fader-gain state, live signal, and free space. Use `--manifest` when a
   manifest exists.
6. After `start`, verify `outputActive=true`. After `stop`, report the returned
   path and verify the media with `scripts/recording-check.mjs`. Do not claim
   success from a request alone.
7. Do not delete, move, overwrite, or remux recordings without a separate,
   explicit user request.
8. Never expose the WebSocket password in output, arguments visible in process
   listings, committed files, or logs.

## Recording actions

```bash
# Idempotent: reports already-active instead of toggling.
obsctl.mjs start

# Require more free space for a long/high-resolution session.
obsctl.mjs start --min-free-gib 100

obsctl.mjs pause
obsctl.mjs resume
obsctl.mjs split
obsctl.mjs chapter "Demo begins"
obsctl.mjs stop
```

`start --force` overrides only the CLI's free-space and visible-video
preflight. It does not repair OBS, validate audio, or make an unsafe profile
safe.

## Live audio meters

`audio` reports configuration. `meters` subscribes to OBS's high-volume
`InputVolumeMeters` event and samples actual signal:

```bash
obsctl.mjs meters --seconds 3
obsctl.mjs meters --seconds 5 --threshold-db -50 --json
```

The report distinguishes raw from post-fader input levels and includes the 95th
percentile so one anomalous sample does not dominate the result. Ask the user to
speak or play the expected desktop audio during the sample. A quiet sample is
evidence only for that time window; it does not prove that a device is broken.

## Recorded media

Inspect the returned recording without modifying it:

```bash
recording-check.mjs "/path/returned/by/StopRecord"
recording-check.mjs "/path/returned/by/StopRecord" --transcribe
```

The command reports container/stream structure, mean and maximum dBFS,
integrated LUFS, true peak, and detected silence. Transcription creates sibling
`.txt`, `.srt`, and `.json` files and refuses to overwrite existing derived
files. Read [media-validation.md](media-validation.md) before interpreting
loudness or handling multiple audio streams.

## Screenshots

Capture the program scene or a named source for visual diagnosis:

```bash
obsctl.mjs screenshot --output /tmp/obs-program.png
obsctl.mjs screenshot --source "Camera" --output /tmp/obs-camera.png
```

The output file is created with mode `0600`. Inspect it with the environment's
image-viewing tool. Remove temporary screenshots when no longer needed.

## Advanced requests

`request` accepts allowlisted read-only OBS WebSocket requests:

```bash
obsctl.mjs request GetVersion
obsctl.mjs request GetInputSettings '{"inputName":"Camera"}'
```

Unknown and mutating requests fail unless `--allow-write` is supplied. Prefer a
dedicated state-aware command. Before any advanced write, read the current
obs-websocket protocol for the installed version and verify the response.
