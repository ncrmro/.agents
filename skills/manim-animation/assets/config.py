"""Shared configuration for every scene in one video.

Copy into manim/<video-slug>/ and replace the palette with the colors from
scenes.md. Every scene file imports from here so the video stays visually
coherent and a palette change is one edit.
"""

from manim import *  # noqa: F403

# --- Palette -----------------------------------------------------------------
# Replace with the hex codes from scenes.md. Keep contrast high: every one of
# these must stay readable against BG_COLOR, including after a camera zoom-out.

BG_COLOR = "#1a1a2e"
GOLD = "#f4a261"
ELECTRIC = "#4cc9f0"
WHITE_TEXT = "#f8f9fa"
DIM = "#6c757d"  # decorative only — never for text the viewer must read

# --- Typography --------------------------------------------------------------
# Manim's default serif font triggers a Pango kerning bug that misaligns
# letters. Every Text() must go through Txt() or pass font= explicitly.
#
# Pick a font that is actually installed — Manim falls back silently, which
# brings the kerning bug straight back. Check before choosing:
#     fc-list : family | tr ',' '\n' | sort -u | grep -i sans
# DejaVu Sans is present on most Linux hosts and renders cleanly.

FONT = "DejaVu Sans"


def Txt(*args, **kwargs):
    """Text() with the project font applied."""
    kwargs.setdefault("font", FONT)
    kwargs.setdefault("color", WHITE_TEXT)
    return Text(*args, **kwargs)  # noqa: F405
