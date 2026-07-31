# Keep OBS out of screen recordings

## Linux and Hyprland result

As of 2026-07-29, OBS on Linux does **not** offer its Windows-only **Hide OBS
windows from screen capture** setting. OBS's settings implementation deletes that
control on non-Windows builds. The installed Linux OBS 32.1.2 therefore cannot
mark its own windows as capture-excluded.

Wayland's ScreenCast portal exposes monitor, window, and virtual-monitor source
types plus cursor and persistence controls. It does not expose a per-window
exclusion list for a monitor stream. A whole-monitor PipeWire capture should
therefore be treated as the compositor's visible monitor output: if OBS is
visible inside the captured area, assume it will be recorded.

## Reliable operator patterns

Prefer these in order:

1. **Capture a window** when the portal/backend offers the required window and
   the recording does not need desktop-wide interactions.
2. **Keep OBS on another normal workspace** and capture the workspace where the
   content is shown. Switch scenes and transport through `obsctl.mjs`, verified
   hotkeys, or another non-captured device.
3. **Minimize OBS to the tray before a whole-monitor recording** if OBS is on the
   captured workspace. Confirm the program scene with a private screenshot
   first, then remove the temporary screenshot.
4. **Use a cropped screen source** only when its boundaries are stable. This
   excludes OBS by geometry, not identity; moving OBS into the crop records it.

A Hyprland special workspace is not a capture-exclusion primitive. Do not assume
its windows are absent while that workspace is shown over the captured output.
Always verify the actual Program scene.

## Evidence

- [OBS settings implementation at commit `0052d02`](https://github.com/obsproject/obs-studio/blob/0052d024fd6a5ff1aa04c76cbdffd3085a5dfacc/frontend/settings/OBSBasicSettings.cpp): the `hideOBSFromCapture` control is retained only inside the `_WIN32` branch and deleted in the non-Windows branch. This is direct implementation evidence, not a promise about future versions.
- [XDG Desktop Portal ScreenCast API](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.ScreenCast.html): source selection supports MONITOR, WINDOW, and VIRTUAL streams; documented `SelectSources` options contain no per-window exclusion facility. Absence from this API does not rule out every compositor-specific extension, but it rules out a portable portal control OBS can request here.
