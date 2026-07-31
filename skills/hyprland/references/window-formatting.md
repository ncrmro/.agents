# Format a workspace's center master for capture

Use the bundled script when a center-master tile should match a recording aspect
ratio. The workspace is mandatory; never infer it from focus.

```sh
SKILL_DIR="${HOME}/.agents/skills/hyprland"
"${SKILL_DIR}/scripts/center-window-for-format.sh" \
  3840x2160 --workspace 1 --dry-run
"${SKILL_DIR}/scripts/center-window-for-format.sh" \
  3840x2160 --workspace 1
```

The script resolves that exact workspace and its monitor, then selects the tiled
window nearest the monitor center. It keeps the tile's current height and asks
the active layout to resize its width to the requested ratio. This changes the
split within that workspace; it does not float or move the window and does not
select a window from another workspace.

When applying the change, the script prints a reversal command first. If
verification fails, it attempts that rollback automatically. Preview with
`--dry-run` and confirm the reported workspace and center-master title before
applying.

## Use the live OBS canvas

OBS owns capture state; Hyprland owns workspace geometry. Keep that dependency in
the OBS workflow rather than teaching the desktop script how to read OBS:

```sh
OBS_SKILL="${HOME}/.agents/skills/obs-recording"
HYPR_SKILL="${HOME}/.agents/skills/hyprland"
format=$("${OBS_SKILL}/scripts/obsctl.mjs" status --json |
  jq -r '"\(.video.outputWidth)x\(.video.outputHeight)"')
"${HYPR_SKILL}/scripts/center-window-for-format.sh" \
  "$format" --workspace 1 --dry-run
```

Only the ratio matters: `1920x1080` and `3840x2160` produce the same split. The
script derives logical monitor geometry from scale and transform before finding
the center. Confirm the Program scene separately because a matching tile ratio
does not prove that OBS captures that tile or crops it correctly.
