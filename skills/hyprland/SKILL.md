---
name: hyprland
description: Configure, automate, and troubleshoot Hyprland desktops using hyprctl and Hyprland configuration. Use for monitor layouts, workspaces and windows, dispatchers and keybinds, input devices, window rules, animations, plugins, session behavior, or diagnosing a running Hyprland compositor.
---

# Hyprland

Inspect the running compositor before changing it, consult documentation matching
the installed version, apply the smallest live change, verify the result, and only
then persist it in configuration.

Read `references/monitors.md` completely when positioning, enabling, disabling,
scaling, rotating, or troubleshooting displays.

## The trap that wastes an afternoon

Hyprland monitor placement is order-sensitive. A directional position on the
first monitor does nothing: the first monitor becomes the anchor at `(0,0)`.
Express the desired relationship on a later monitor. For example, if the laptop
panel is the anchor and the external monitor belongs above it, place the external
monitor at `auto-center-up`; this is equivalent to placing the laptop below the
external monitor.

## Core workflow

1. Detect the installed Hyprland version and active state.
2. Inspect the relevant runtime objects with `hyprctl ... -j`.
3. Check the documentation for that version. Hyprland syntax changes quickly;
   do not assume latest-git configuration syntax matches the installed release.
4. Explain any visible or disruptive effect before applying it.
5. Test with a live `hyprctl` change.
6. Query runtime state again and verify geometry or behavior numerically.
7. Locate the actual sourced configuration and persist only after the live result
   is correct or when the user explicitly asks for persistence.

## Inspection

Prefer JSON output and `jq` over parsing human-readable output.

| Need | Command |
| --- | --- |
| Version | `hyprctl version` |
| Monitors and geometry | `hyprctl monitors -j` |
| Workspaces | `hyprctl workspaces -j` |
| Windows | `hyprctl clients -j` |
| Active window | `hyprctl activewindow -j` |
| Active workspace | `hyprctl activeworkspace -j` |
| Devices | `hyprctl devices -j` |
| Configuration errors | `hyprctl configerrors` |
| Instances | `hyprctl instances -j` |

Use `rg` to locate configuration declarations and `source` chains. Preserve the
user's configuration structure and ownership boundaries; do not assume
`~/.config/hypr/hyprland.conf` contains the effective rule.

## Live changes

- Use `hyprctl dispatch ...` for compositor actions.
- Use `hyprctl keyword ...` to test legacy/hyprlang-style configuration values
  supported by the running version.
- Use `hyprctl --batch 'command; command'` when multiple runtime changes must be
  applied together.
- Treat runtime changes as temporary. Reloads, config watchers, hotplug events,
  or logout can replace them.
- Re-query state after every layout-affecting operation. An `ok` response means
  Hyprland accepted the command, not that the resulting layout matches intent.

## Safety

- Do not call `hyprctl dispatch exit` unless the user explicitly requests ending
  the compositor session.
- Avoid disabling the only usable monitor.
- Before moving every workspace or window, identify pinned windows and special
  workspaces and state whether they are included.
- Preserve resolution, refresh rate, scale, transform, VRR, and color settings
  unless the task specifically changes them.
- For disruptive changes, keep a known-good reversal command ready.

## Documentation

Prefer the official Hyprland Wiki and select the installed release with its
version selector when possible. The latest-git wiki may describe Lua
configuration while an installed release still uses hyprlang syntax.
