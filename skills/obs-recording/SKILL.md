---
name: obs-recording
description: Set up, inspect, safely operate, and troubleshoot OBS Studio recordings with bundled obs-websocket scripts, optional MCP, media checks, and local transcription. Use for recording controls; scene, source, and audio audits; screenshots; output validation; or diagnosis of WebSocket, PipeWire/portal, dropped-frame, encoder, storage, and media failures.
---

# OBS recording

Prefer the bundled direct WebSocket CLI for control and cross-checks. MCP is
optional: it does not replace host logs, disk checks, portal diagnostics, or
output validation.

## Workflow

1. Run the read-only doctor:

   ```bash
   "${HOME}/.agents/skills/obs-recording/scripts/obsctl.mjs" doctor
   ```

2. If audio matters, sample live signal while the user speaks or plays the
   expected desktop audio:

   ```bash
   "${HOME}/.agents/skills/obs-recording/scripts/obsctl.mjs" meters --seconds 3
   ```

3. If the user has a desired layout, copy a manifest from `assets/scenes/`,
   customize exact names, then run:

   ```bash
   "${HOME}/.agents/skills/obs-recording/scripts/obsctl.mjs" \
     doctor --manifest /path/to/scene.json
   ```

4. Resolve findings one layer at a time. Read
   [references/diagnostics.md](references/diagnostics.md) for symptom routing.
5. Before any state change, read
   [references/operations.md](references/operations.md) and report the intended
   scene, visible sources, audio mute/fader state, output directory, and free
   space.
6. Use explicit commands (`start`, `stop`, `pause`, `resume`); never emulate
   them with a toggle. Verify the observed state after every write.
7. After stopping, report the returned path and run
   `scripts/recording-check.mjs <path>`. Add `--transcribe` when a transcript is
   requested. Transcription delegates to media-editor and classifies Vulkan,
   Metal, or CUDA from runtime-log markers. Successful JSON reports include the
   backend, device label, CPU fallback reason, and diarization decision. With
   `--require-gpu`, a CPU classification exits early and writes the reason to
   stderr. Use `--diarize auto|always|never` to choose the policy. Read
   [references/media-validation.md](references/media-validation.md) for
   interpretation and multi-speaker escalation.
8. Never delete, move, overwrite, normalize, or remux a recording without a
   separate explicit request.

## Choose the control path

- Use `scripts/obsctl.mjs` when MCP is unavailable or failing.
- When MCP is connected, use it for discovery and operations, but cross-check
  important state and output with the script.
- When selecting or packaging an MCP server, read
  [references/mcp.md](references/mcp.md). Require reproducible packaging,
  loopback/secret safety, live-version discovery, state-aware retries, and
  end-to-end media validation.

## Safety rules

- Treat WebSocket credentials as secrets. Never print or commit them.
- Treat start/stop/pause/resume, screenshots, scene/source/audio/profile changes,
  and raw requests as writes.
- Do not reconfigure profiles, collections, encoders, paths, or devices during
  an active recording.
- Use `request` only for read-only calls. Unknown calls require
  `--allow-write`; inspect the installed protocol before using it.
- Do not copy raw OBS scene collection JSON as a portable template. It can
  contain device identifiers, plugin state, and portal restore tokens.
- Keep remote obs-websocket exposure out of scope unless the user explicitly
  requests a secured remote-control design.

## Resources

- `scripts/obsctl.mjs` — dependency-free Node 22+ authenticated obs-websocket
  CLI; use `help` for commands.
- `scripts/recording-check.mjs` — read-only media structure, loudness, peak, and
  silence checks; optional transcription delegates to media-editor and embeds
  backend/device/diarization metadata in the JSON report.
- `scripts/transcribe-recording.sh` — thin adapter to the shared interface.
- `assets/scenes/` — copyable operator manifests for screen-only and
  screen-plus-camera layouts.
- `assets/masks/circle-480.png` — reusable centered alpha mask for circular
  camera overlays.
- `assets/sources/source-template.json` — source expectation snippet.
- [references/templates.md](references/templates.md) — manifest schema and
  platform source-kind guidance.
- [references/diagnostics.md](references/diagnostics.md) — symptom-to-check map.
- [references/operations.md](references/operations.md) — command and validation
  contract.
- [references/media-validation.md](references/media-validation.md) — recorded
  audio interpretation and transcription workflow.
- [references/workflows.md](references/workflows.md) — common agent-operated OBS
  workflows and their local implementation.
- [references/mcp.md](references/mcp.md) — optional MCP acceptance gate.

If Node lacks a built-in `WebSocket`, stop and use the project's Nix environment
to provide Node 22+; do not install a runtime globally.
