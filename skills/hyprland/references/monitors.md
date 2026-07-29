# Hyprland monitors

Read this reference completely for monitor work.

## Start with runtime truth

```sh
hyprctl version
hyprctl monitors -j
```

Summarize each display's connector name, description, logical size, position,
scale, transform, refresh rate, focus, and active workspace. Connector names can
change across docks and boots; use `desc:` matching for persistent rules when
port stability is uncertain.

## Positioning model

Positions use logical pixels after scale and transform. Monitors may not overlap.
Hyprland normalizes the layout, so negative coordinates are valid and do not
indicate a problem.

| Position | Effect |
| --- | --- |
| `auto` | Let Hyprland place the monitor, normally to the right |
| `auto-right`, `auto-left`, `auto-up`, `auto-down` | Place by the monitors' top-left origins |
| `auto-center-right`, `auto-center-left`, `auto-center-up`, `auto-center-down` | Place using monitor centers |

Use center variants when differently sized displays should be visually centered.

## The first-monitor ordering rule

The first declared/evaluated monitor is the anchor. A direction on that first
monitor is accepted but ignored; it is positioned at `(0,0)`. Directions apply
to subsequent monitors, moving outward from the center.

This creates a common misleading failure:

1. The laptop panel is the first monitor.
2. Set the laptop to `auto-center-down`.
3. Hyprland keeps the laptop at the origin.
4. Another monitor's existing `auto` rule places it to the right.
5. The result is a row, sometimes touching only at opposite corners, even though
   the command returned `ok`.

Fix the relationship from the non-anchor monitor:

```sh
# Laptop is the anchor; put the external display above it.
hyprctl keyword monitor 'DP-4,preferred,auto-center-up,1'
```

This yields the same physical arrangement as "laptop below external" without
requiring the laptop itself to use `auto-center-down`.

For persistent configuration, declare the anchor first and dependent displays
after it. Use the syntax appropriate to the installed Hyprland version.

## Live test and verification

```sh
hyprctl keyword monitor 'OUTPUT,preferred,auto-center-up,1'
hyprctl monitors -j |
  jq -r '.[] | "\(.name): \(.width)x\(.height) at \(.x),\(.y), scale \(.scale)"'
```

For a monitor centered above another, its bottom edge equals the lower monitor's
top edge and their logical horizontal centers are equal. For a monitor centered
below another, its top edge equals the upper monitor's bottom edge and their
logical horizontal centers are equal. Compute using logical dimensions after
scale and transform.

## Preserve existing display properties

Before changing only position, record mode, refresh, scale, transform, VRR, and
color settings. `preferred` and scale `1` are convenient examples but may change
a HiDPI user's intended setup. Carry forward existing values or use the installed
version's syntax for changing position alone.

When several rules interact, batching reduces intermediate layout churn but does
not override the first-monitor ordering rule:

```sh
hyprctl --batch 'keyword monitor ANCHOR,...; keyword monitor DEPENDENT,...'
```

## Moving windows and workspaces

Moving a workspace moves its contained windows while preserving its layout:

```sh
hyprctl dispatch movecurrentworkspacetomonitor OUTPUT
hyprctl dispatch moveworkspacetomonitor 'WORKSPACE OUTPUT'
```

To move all normal workspaces from one monitor:

```sh
hyprctl workspaces -j |
  jq -r '.[] | select(.monitor == "SOURCE" and .id > 0) | .id' |
  while read -r workspace; do
    hyprctl dispatch moveworkspacetomonitor "$workspace TARGET"
  done
```

Decide separately whether special workspaces, pinned windows, and scratchpads
belong in scope.

## Diagnostics

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Command returns `ok`, but displays remain in a row | Direction was assigned to the first/anchor monitor | Put the inverse direction on the other monitor, or reorder persistent declarations |
| Displays touch only at a corner | Existing rule positioned the non-anchor display in another direction | Inspect all effective rules; set the relationship on the dependent display |
| Coordinates are negative | Hyprland normalized a layout extending left/up from the anchor | Accept them if edge and center equations are correct |
| Layout works live but reverts | Runtime keyword was temporary or configuration watcher reapplied rules | Update the actual sourced configuration |
| Scale or refresh changes unexpectedly | A full monitor rule supplied new defaults | Preserve the existing mode, refresh, and scale |
| Rule works differently from the wiki | Latest-git docs do not match installed release | Use `hyprctl version` and select matching wiki docs |

## Official reference

Use the Hyprland monitor documentation matching the installed version:
`https://wiki.hypr.land/Configuring/Basics/Monitors/`.
