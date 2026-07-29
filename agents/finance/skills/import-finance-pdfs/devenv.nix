{ pkgs, lib, ... }:

let
  wheelLibs = [
    pkgs.libxcb
    pkgs.libglvnd
    pkgs.glib
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib
  ];
in
{
  packages = [
    pkgs.uv
  ] ++ wheelLibs;

  env.LD_LIBRARY_PATH = lib.makeLibraryPath wheelLibs;

  enterShell = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';

  enterTest = ''
    export PATH="$HOME/.local/bin:$PATH"
    docling --version >/dev/null
  '';
}
