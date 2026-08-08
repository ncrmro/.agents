{ pkgs, ... }:

# Toolchain for one animation project. Copy into manim/<video-slug>/ and let
# direnv load it. Nothing is installed globally.
#
# Verified attributes on nixpkgs: manim 0.20.1, texlive 2025, uv 0.12.
{
  packages = with pkgs; [
    # ManimCE, plus its cairo/pango stack.
    manim

    # LaTeX, for MathTex. texliveMedium covers ordinary mathematics.
    # If a render fails with a missing .sty, switch to texliveFull rather than
    # hunting individual packages — the disk is cheaper than the afternoon.
    texliveMedium

    # Assembly and probing.
    ffmpeg

    # Only needed if the project pins its own Python dependencies beyond manim.
    uv
  ];

  enterShell = ''
    echo "manim   $(manim --version 2>/dev/null | head -1)"
    echo "latex   $(latex --version 2>/dev/null | head -1)"
    echo "ffmpeg  $(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f1-3)"
  '';
}
