# Environment dependencies

Read this when a source-ingest preflight check reports a missing tool or a tool
fails at runtime.

## NixOS

Prefer a project devenv over per-command library-path workarounds. The
environment needs:

- `ffmpeg`
- `whisper-cpp`
- `uv`
- `libxcb`, `libglvnd`, `glib`, `zlib`, and the C++ runtime for Docling's
  manylinux wheels

Install Docling through uv because the nixpkgs package may be broken:

```bash
uv tool install docling
```

Run ingestion inside the configured environment:

```bash
devenv shell -- docling <source.pdf> --to md --output <output-directory> --image-export-mode placeholder
```

If Docling reports a missing shared library, add its providing nixpkgs package
to the project's devenv rather than setting an ad hoc global
`LD_LIBRARY_PATH`.

## Whisper models

Store local Whisper models under `~/.cache/whisper/`. Model downloads can be
large; obtain confirmation before downloading a multi-gigabyte model.

Docling downloads its layout and OCR models on first use. Run the first
conversion as a background task when appropriate.
