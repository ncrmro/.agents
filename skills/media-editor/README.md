# media-editor — platform notes & known issues

Operational caveats for this skill's toolchain. The behavioral instructions live
in `SKILL.md`; this file records environment gotchas worth knowing before you
debug them the hard way.

## GPU acceleration is asymmetric on AMD

Measured on an AMD **Radeon RX 9070 XT (RADV GFX1201, RDNA4)**:

- **`whisper-cli` (whisper.cpp) — GPU works.** The devenv ships
  `whisper-cpp-vulkan`, which offloads to the GPU via the Vulkan backend
  automatically (`use gpu = 1`, `using Vulkan0 backend`). This is the fast local
  transcription path on AMD.
- **`whisperx` — CPU only on AMD.** whisperx's ASR engine is **CTranslate2
  (faster-whisper), which is CUDA-only** — it cannot target an AMD GPU. On top of
  that, the nixpkgs `whisperx` pulls **CPU-only torch** (`torch.cudaSupport =
  false`), so its VAD/alignment/diarization torch models also run on CPU. This is
  an upstream limitation, not a misconfiguration.

Consequence: for GPU-accelerated transcription on AMD, use `whisper-cli`
(Vulkan). Reach for whisperx only when you need diarization, and accept that it
runs on CPU here (fine for the diarization overlay; the expensive ASR should go
through whisper.cpp-vulkan when speed matters).

A future GPU-diarization path exists — nixpkgs has `torchWithRocm`, and Ollama
already GPU-runs on this card via ROCm — but overriding whisperx to use ROCm
torch on gfx1201 is bleeding-edge (likely needs `HSA_OVERRIDE_GFX_VERSION`, may
not build), and CTranslate2 would still keep ASR on CPU. Deferred by choice.

## whisperx diarization needs *accepted* gated models, not just a token

Setting `HF_TOKEN` is necessary but **not sufficient**. pyannote's diarization
pipelines are **gated models**: the account that owns the token must click
"Agree and access repository" on each required model page. Otherwise whisperx
fails with:

```
huggingface_hub.errors.GatedRepoError: 403 Client Error.
Access to model pyannote/speaker-diarization-… is restricted and you are not in
the authorized list.
```

To fix, with the **same HF account** as your token, accept access on:

- <https://hf.co/pyannote/speaker-diarization-community-1> — whisperx's **default**
  `--diarize_model`, or
- <https://hf.co/pyannote/speaker-diarization-3.1> — pass it via
  `--diarize_model pyannote/speaker-diarization-3.1`
- <https://hf.co/pyannote/segmentation-3.0> — a **dependency** of the 3.1
  pipeline; accept it too.

Access approval is usually instant. Put the token in a gitignored `.env`
(`cp .env.example .env`; see `setup-tools.md`) — the devenv (`dotenv`) and
`scripts/deps-doctor.sh` both load it. The doctor reports whether the token is
set, but it cannot verify per-model access grants.

## devenv pins upstream nixpkgs, not devenv-nixpkgs/rolling

`devenv.yaml` points `nixpkgs` at `github:NixOS/nixpkgs/nixpkgs-unstable`. The
usual `cachix/devenv-nixpkgs/rolling` fork currently ships a **broken
`ctranslate2`** (fixed-output hash mismatch) that fails the whisperx build;
upstream nixpkgs-unstable builds and caches the whole torch stack.

## docling is optional and can fail in the isolated shell

The devenv's `LD_LIBRARY_PATH` is scoped to the wheel libs whisper/torch need;
docling's OpenCV wheel may still miss a system library and error on
`docling --version`. It's treated as optional — `enterTest` and the doctor never
fail on it.
