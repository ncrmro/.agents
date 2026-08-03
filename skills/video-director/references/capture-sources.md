# Capture sources

Read only the sections for the sources in the current scene.

## Terminal

Use `asciinema` to record a real terminal session as a cast file.

### Prepare

1. Check that `asciinema` is on `PATH`.
2. Check that `agg` is on `PATH` when the edit needs a GIF.
3. Use a fixed terminal size.
4. Use a clean prompt that does not show private paths or repository state.
5. Prepare the exact command list.
6. Remove commands that can expose credentials or secret environment values.
7. Use deterministic input data.

### Capture

1. Start `asciinema` with a path under `raw/`.
2. Run only the approved commands.
3. Wait for each expected result.
4. Stop the recording after the scene result is visible.
5. Replay the cast with `asciinema play`.

Keep the cast file as the raw artifact. Use `agg` to create a GIF when the
editor needs pixels. Put the GIF under `derived/`. FFmpeg can read the derived
GIF during the final edit.

Inspect `asciinema rec --help` and `agg --help` before you select flags. Tool
versions can have different command options.

## Browser

Use a browser automation tool as the driver. Use OBS as the default recorder
for a live browser window.

### Prepare

1. Read the `browser-mcp` skill.
2. Read the `obs-recording` skill.
3. Use an isolated browser profile.
4. Set a fixed viewport and window position.
5. Decide if the browser frame is part of the demo.
6. Use one tab unless the story requires more tabs.
7. Seed the required application state.
8. Remove extensions, saved accounts, and unrelated history.

### Capture

1. Select and check the OBS scene.
2. Start the OBS recording.
3. Use semantic browser targets when possible.
4. Check the page state after each action.
5. Take a still screenshot of the final state.
6. Stop the OBS recording.
7. Run the recording check from `obs-recording`.

Do not accept a successful browser action as proof of a successful picture.
Check a screenshot or the visible page state.

## Desktop

Use OBS as the default recorder. Use an available desktop automation tool as
the driver. The user MAY perform actions when no safe automation tool exists.

### Prepare

1. Read the `obs-recording` skill.
2. Put the application on a dedicated workspace.
3. Set a fixed window size and position.
4. Close or hide unrelated applications.
5. Disable visible notifications.
6. Check that file pickers and system dialogs cannot expose private paths.
7. Rehearse the interaction from a known application state.
8. Prefer semantic or accessibility targets over pixel coordinates.

### Capture

1. Select and check the OBS scene.
2. Start the OBS recording.
3. Run the approved desktop actions.
4. Check the application state after each action.
5. Stop the OBS recording.
6. Run the recording check from `obs-recording`.

Desktop automation is more fragile than terminal or browser automation. Use
short scenes. Reset the application before each retry.

## Multi-source scenes

Select the recording topology before capture.

| Need | Topology |
| --- | --- |
| Terminal and one pixel source | Record the terminal cast and the OBS video concurrently. |
| Browser and desktop in one fixed layout | Compose both sources in one OBS scene. |
| Independent browser and desktop edits | Use separate recorders or a verified source-recording setup. |
| Three independent live sources | Record the terminal cast and two independent pixel streams. |

Use a shared event log for all concurrent sources. Write one JSON object per
line. Use UTC timestamps.

```json
{"time":"2026-08-03T18:00:00.000Z","scene":"deploy","event":"capture-start","source":"terminal"}
{"time":"2026-08-03T18:00:01.200Z","scene":"deploy","event":"sync","marker":"deploy-01"}
{"time":"2026-08-03T18:00:03.000Z","scene":"deploy","event":"action","action":"run-deploy"}
```

A timestamp is an editing aid. It does not prove frame-accurate
synchronization. Use a visible or audible marker when exact synchronization
matters.
