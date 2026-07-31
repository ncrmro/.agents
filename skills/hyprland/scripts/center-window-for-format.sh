#!/usr/bin/env bash
# Resize one workspace's tiled center-master window to a requested aspect ratio.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: center-window-for-format.sh WIDTHxHEIGHT --workspace NAME [--dry-run]

Required:
  --workspace NAME  Target this exact Hyprland workspace name or numeric ID.

Options:
  --dry-run         Print the selected workspace, master window, and command.
  -h, --help        Show this help.

The script finds the tiled window nearest the target workspace's monitor center,
keeps its current height, and adjusts the master-layout width to the requested
aspect ratio. It never floats or moves a window and never touches another
workspace. Applying prints a reversal command and verifies the resulting ratio.
EOF
}

die() {
  printf 'center-window-for-format: %s\n' "$*" >&2
  exit 2
}

(( $# )) || { usage >&2; exit 2; }
format=$1
shift
workspace_name=
dry_run=false

while (( $# )); do
  case $1 in
    --workspace)
      (( $# >= 2 )) || die '--workspace requires a name or ID'
      workspace_name=$2
      shift 2
      ;;
    --dry-run) dry_run=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

[[ $format =~ ^([1-9][0-9]*)x([1-9][0-9]*)$ ]] ||
  die "format must be WIDTHxHEIGHT, got: $format"
[[ -n $workspace_name ]] || die '--workspace is required; never infer it from focus'
format_width=${BASH_REMATCH[1]}
format_height=${BASH_REMATCH[2]}

command -v hyprctl >/dev/null || die 'hyprctl is unavailable'
command -v jq >/dev/null || die 'jq is unavailable'

workspaces=$(hyprctl workspaces -j)
monitors=$(hyprctl monitors -j)
clients=$(hyprctl clients -j)
workspace=$(jq -ce --arg workspace "$workspace_name" '
  first(.[] | select(.name == $workspace or (.id | tostring) == $workspace)) // empty
' <<<"$workspaces") || die "workspace not found: $workspace_name"
workspace_id=$(jq -r '.id' <<<"$workspace")
workspace_name=$(jq -r '.name' <<<"$workspace")
monitor_name=$(jq -r '.monitor' <<<"$workspace")
monitor=$(jq -ce --arg monitor "$monitor_name" '
  first(.[] | select(.name == $monitor)) // empty
' <<<"$monitors") || die "monitor not found for workspace $workspace_name: $monitor_name"

monitor_x=$(jq -r '.x' <<<"$monitor")
monitor_y=$(jq -r '.y' <<<"$monitor")
scale=$(jq -r '.scale' <<<"$monitor")
transform=$(jq -r '.transform' <<<"$monitor")
read -r pixel_width pixel_height < <(jq -r '[.width, .height] | @tsv' <<<"$monitor")
read -r reserved_left reserved_top reserved_right reserved_bottom < <(
  jq -r '.reserved | @tsv' <<<"$monitor"
)

# Client and dispatcher geometry use logical compositor coordinates.
if [[ $transform == 1 || $transform == 3 || $transform == 5 || $transform == 7 ]]; then
  logical_width=$(awk -v value="$pixel_height" -v scale="$scale" 'BEGIN { printf "%.0f", value / scale }')
  logical_height=$(awk -v value="$pixel_width" -v scale="$scale" 'BEGIN { printf "%.0f", value / scale }')
else
  logical_width=$(awk -v value="$pixel_width" -v scale="$scale" 'BEGIN { printf "%.0f", value / scale }')
  logical_height=$(awk -v value="$pixel_height" -v scale="$scale" 'BEGIN { printf "%.0f", value / scale }')
fi
usable_x=$((monitor_x + reserved_left))
usable_y=$((monitor_y + reserved_top))
usable_width=$((logical_width - reserved_left - reserved_right))
usable_height=$((logical_height - reserved_top - reserved_bottom))
(( usable_width > 0 && usable_height > 0 )) || die 'workspace monitor has no usable area'

center_x=$((usable_x + usable_width / 2))
center_y=$((usable_y + usable_height / 2))
target=$(jq -ce \
  --argjson workspace "$workspace_id" \
  --argjson center_x "$center_x" \
  --argjson center_y "$center_y" '
  [
    .[] |
    select(.workspace.id == $workspace and .mapped and (.hidden | not) and (.floating | not)) |
    . + {distance: (
      (((.at[0] + .size[0] / 2) - $center_x) | . * .) +
      (((.at[1] + .size[1] / 2) - $center_y) | . * .)
    )}
  ] | sort_by(.distance) | first // empty
' <<<"$clients") || die "no tiled window found on workspace $workspace_name"

address=$(jq -r '.address' <<<"$target")
class=$(jq -r '.class' <<<"$target")
title=$(jq -r '.title' <<<"$target")
old_width=$(jq -r '.size[0]' <<<"$target")
old_height=$(jq -r '.size[1]' <<<"$target")
target_height=$old_height
target_width=$((target_height * format_width / format_height))
(( target_width <= usable_width )) ||
  die "requested ratio needs width $target_width at the master's current height $target_height; workspace has only $usable_width logical pixels"
selector="address:$address"
initial_delta=$((target_width - old_width))
reversal="hyprctl dispatch resizewindowpixel '$((-initial_delta)) 0,$selector'"

printf 'Workspace: %s (id %s) on %s\n' "$workspace_name" "$workspace_id" "$monitor_name"
printf 'Center master: %s [%s] · %s\n' "$title" "$class" "$address"
printf 'Geometry: %sx%s → %sx%s (format %s)\n' \
  "$old_width" "$old_height" "$target_width" "$target_height" "$format"
printf 'Revert: %s\n' "$reversal"

$dry_run && {
  printf "Dry run: hyprctl dispatch resizewindowpixel '%s 0,%s'\n" "$initial_delta" "$selector"
  exit 0
}

mutated=false
rollback() {
  if $mutated; then
    printf 'Verification failed; attempting rollback.\n' >&2
    current_width=$(hyprctl clients -j | jq -r --arg address "$address" \
      'first(.[] | select(.address == $address)).size[0] // empty')
    if [[ -n $current_width ]]; then
      hyprctl dispatch resizewindowpixel "$((old_width - current_width)) 0,$selector" >/dev/null 2>&1 || true
    fi
  fi
}
trap rollback EXIT
mutated=true

# Tiled layouts can round a requested delta. Re-read and correct at most twice.
for _ in 1 2 3; do
  current=$(hyprctl clients -j | jq -ce --arg address "$address" \
    'first(.[] | select(.address == $address)) // empty') ||
    die 'center-master window disappeared before verification'
  current_width=$(jq -r '.size[0]' <<<"$current")
  delta=$((target_width - current_width))
  (( delta == 0 )) && break
  hyprctl dispatch resizewindowpixel "$delta 0,$selector" >/dev/null
done

updated=$(hyprctl clients -j | jq -ce --arg address "$address" '
  first(.[] | select(.address == $address)) // empty
') || die 'center-master window disappeared before verification'
new_workspace=$(jq -r '.workspace.name' <<<"$updated")
new_width=$(jq -r '.size[0]' <<<"$updated")
new_height=$(jq -r '.size[1]' <<<"$updated")
new_floating=$(jq -r '.floating' <<<"$updated")
ratio_error=$((new_width * format_height - new_height * format_width))
(( ratio_error < 0 )) && ratio_error=$((-ratio_error))

[[ $new_workspace == "$workspace_name" && $new_floating == false ]] ||
  die "workspace invariant failed: workspace=$new_workspace floating=$new_floating"
# Hyprland may round a tiled split by a pixel; tolerate that and no more.
(( ratio_error <= format_height )) ||
  die "ratio verification failed: observed ${new_width}x${new_height}, expected $format"

mutated=false
trap - EXIT
printf 'Verified workspace %s only: %sx%s, tiled, aspect %.4f\n' \
  "$workspace_name" "$new_width" "$new_height" \
  "$(awk -v width="$new_width" -v height="$new_height" 'BEGIN { print width / height }')"
