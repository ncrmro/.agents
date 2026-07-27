# OBS recording diagnostics

## Triage order

1. Run `scripts/obsctl.mjs doctor --json`.
2. Read the latest OBS log with `scripts/obsctl.mjs logs`.
3. Capture the program scene with `scripts/obsctl.mjs screenshot`.
4. Compare the intended scene against a copied manifest with
   `doctor --manifest <file>`.
5. Change one layer at a time: process/config, WebSocket, scene/source, audio,
   encoder/output, then media file.

## Symptom map

| Symptom | Check | Likely cause / next action |
| --- | --- | --- |
| Cannot connect | `doctor`; OBS process; WebSocket settings | OBS is stopped, server disabled, wrong port/password, or client is not on the same network namespace. |
| Authentication fails | `auth_required`; configured secret source | Password drift. Re-enter it in OBS and the secret manager; never disable auth as a shortcut. |
| Black recording | `sources`; program screenshot | Wrong scene, hidden source, stale window target, or screen portal selection missing. |
| Source clipped/off-screen | `doctor`; source transform; program screenshot | The source's dimensions, crop, scale, or alignment place part of it outside the canvas. Fit/reposition it in OBS, then verify visually. |
| Screen source prompts again | source settings and portal logs | PipeWire restore token is absent/revoked. Re-select once in OBS; do not fabricate or copy portal tokens. |
| Camera missing | `sources`; `GetInputSettings`; OBS log | Device disconnected, portal permission missing, or the saved device identifier changed. |
| No microphone | `audio`; `meters` while speaking; PipeWire/Pulse source | Muted input, zero fader, wrong device, unavailable source, or track not routed to the recording. |
| Desktop audio absent | `audio`; `meters` while playing sound; monitoring/source duplication | Zero fader gain, wrong output monitor, muted source, or the same device is incorrectly used for monitoring and capture. |
| Choppy output | `GetStats`; log; encoder settings | Skipped rendering or output frames, encoder overload, or a 4K/60 workload that exceeds the current GPU or encoder. |
| Recording stops/fails | disk state; output path; log | Low disk, unwritable directory, encoder init failure, or output collision. |
| Valid request fails | `GetVersion.availableRequests` | MCP/script tool drifted from the installed obs-websocket version. Discover against the live server. |
| Stop succeeded but file is bad | returned path; `ffprobe`; container | An interrupted recording in a non-resilient container, a zero-duration capture, or missing tracks. Preserve the original before repair/remux. |

## Storage

OBS reports available space through `GetStats`; the doctor also checks the
filesystem containing the recording directory. Treat either of these as a
warning:

- less than the chosen absolute floor (`20 GiB` by default);
- less than 10% of the recording filesystem.

High-resolution, high-frame-rate, or lossless profiles need a larger explicit
floor. Estimate from a representative recording before unattended operation.

## Logs

OBS logs normally live under `~/.config/obs-studio/logs/`. Preserve the full log
when escalating. The quick log command extracts recent lines containing error,
failure, warning, overload, skipped-frame, or audio-buffering terms; it is a
triage filter, not a complete diagnosis.

## Output validation

After stopping, validate without mutating:

```bash
ffprobe -v error \
  -show_entries format=duration,size:stream=index,codec_type,codec_name \
  -of json "/path/returned/by/StopRecord"
```

Require a positive duration and the expected video/audio streams. Do not remux
or replace the original until validation evidence is recorded.
