#!/usr/bin/env bash
# Render every scene at one quality level.
#
#   ./render.sh l   480p15   preview, fast, disposable
#   ./render.sh m   720p30
#   ./render.sh h   1080p60  final
#   ./render.sh k   4K
#
# LaTeX and ffmpeg come from the devenv shell. Do not hardcode a TeX path —
# that is a macOS habit that breaks everywhere else.
set -euo pipefail

QUALITY="${1:-l}"
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

command -v manim >/dev/null || {
	echo "manim not found — enter the devenv shell first" >&2
	exit 1
}

# One entry per scene, in narrative order: "<file> <ClassName>"
scenes=(
	"scene01_hook.py SceneOneHook"
	# "scene02_reveal.py SceneTwoReveal"
)

echo "=== rendering ${#scenes[@]} scene(s) at quality: $QUALITY ==="

for entry in "${scenes[@]}"; do
	file="${entry%% *}"
	class="${entry##* }"
	echo
	echo "--- $class  ($file) ---"
	# --disable_caching avoids the trap where an edited self.wait() is ignored
	# because Manim reused a cached partial movie file.
	manim -q"$QUALITY" --disable_caching "$file" "$class"
done

echo
echo "=== done. output under media/videos/ ==="
