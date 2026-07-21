{ pkgs, lib, ... }:

# Reproducible media-transcription toolchain. Enter with `devenv shell`, run a
# single command with `devenv shell -- <cmd>`, and sanity-check the whole thing
# with `devenv test`. Project-agnostic: no hostnames or consumer paths — point
# at a specific Ollama endpoint via the OLLAMA_HOST env var, not this file.
#
# Use directly (cd into the skill dir), or copy `packages` / `enterShell` /
# `enterTest` into a consuming repo's own devenv.nix.

let
  # System libraries the docling/torch manylinux wheels dlopen() at runtime but
  # that NixOS does not provide globally (the classic `libxcb.so.1` ImportError).
  # Add more here if a new `libXXX.so` import error appears.
  wheelLibs = [
    pkgs.libxcb
    pkgs.libglvnd # libGL
    pkgs.glib
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib # libstdc++
  ];
in
{
  packages = [
    pkgs.ffmpeg # audio/video → 16 kHz mono WAV; cutting/encoding
    pkgs.whisper-cpp-vulkan # whisper-cli, GPU-accelerated via Vulkan (falls back to CPU)
    pkgs.whisperx # multi-speaker diarization (faster-whisper + pyannote)
    pkgs.uv # docling is installed as a uv tool (nixpkgs#docling is broken)
    pkgs.python3
    pkgs.curl # model downloads + Ollama endpoint probing
    pkgs.jq # parse Ollama /api/tags and JSON doctor output
  ] ++ wheelLibs;

  # docling/torch bundled wheels dlopen these at runtime.
  env.LD_LIBRARY_PATH = lib.makeLibraryPath wheelLibs;

  # Load a gitignored `.env` (HF_TOKEN, OLLAMA_HOST overrides) if present.
  dotenv.enable = true;

  enterShell = ''
    export PATH="$HOME/.local/bin:$PATH" # uv-installed docling lives here
    command -v docling >/dev/null 2>&1 || uv tool install docling

    # Informational, non-fatal: surface any missing pieces on shell entry.
    bash "$DEVENV_ROOT/scripts/deps-doctor.sh" -q || true
  '';

  # `devenv test` verifies the required toolchain runs. Optional tools
  # (docling, Ollama) are probed but never fail the test.
  enterTest = ''
    export PATH="$HOME/.local/bin:$PATH" # uv-installed docling lives here
    ffmpeg -version >/dev/null
    whisper-cli --help >/dev/null
    whisperx --help >/dev/null
    docling --version >/dev/null 2>&1 \
      && echo "docling: ok" || echo "docling: unavailable (optional PDF ingest)"
    curl -fs --max-time 4 "''${OLLAMA_HOST:-http://localhost:11434}/api/version" >/dev/null \
      && echo "ollama: reachable" || echo "ollama: not reachable (optional)"
  '';

  scripts.deps-doctor.exec = ''bash "$DEVENV_ROOT/scripts/deps-doctor.sh" "$@"'';
}
