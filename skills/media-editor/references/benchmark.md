# Whisper.cpp CPU versus Vulkan benchmark

Read this reference before estimating transcription time or claiming a GPU
speedup. It records one controlled benchmark, not a universal performance
guarantee.

## Result

Measured on 2026-07-29 with an AMD Radeon RX 9070 XT:

| Backend | Wall time | Processing rate |
| --- | ---: | ---: |
| CPU (`libggml-cpu-haswell`) | 143.936 s | 2.916× real-time |
| Vulkan (`RADV GFX1201`) | 23.449 s | 17.897× real-time |

For this workload, Vulkan was **6.138× faster** and reduced transcription wall
time by **83.7%**.

## Controlled workload

- whisper.cpp 1.8.4 for both runs
- `ggml-small.en-tdrz.bin` model
- one 419.669-second, 16 kHz mono PCM WAV
- identical `whisper-cli` arguments
- JSON output enabled for both runs
- audio extraction and Nix package resolution excluded from the timings

The source media was extracted once and reused:

```bash
ffmpeg -hide_banner -loglevel error -nostdin \
  -i input.mkv -map 0:a:0 -vn \
  -acodec pcm_s16le -ar 16000 -ac 1 benchmark.wav
```

Each backend then ran the same command shape:

```bash
whisper-cli \
  -m ggml-small.en-tdrz.bin \
  -f benchmark.wav \
  --output-json \
  --output-file OUTPUT_BASE
```

The CPU log identified `libggml-cpu-haswell`. The GPU log identified the AMD
Radeon RX 9070 XT and loaded `libggml-vulkan.so`. Binary presence alone was not
accepted as GPU evidence.

## Internal timing evidence

The backend timing summaries help explain the overall difference:

| Stage | CPU | Vulkan |
| --- | ---: | ---: |
| Encode | 37.762 s | 0.693 s |
| Batched decode | 92.490 s | 14.682 s |
| Total reported by whisper.cpp | 143.802 s | 22.967 s |

## Limits

- This is one run per backend on one machine and one model.
- The CPU ran first. The Vulkan run may have benefited from warm filesystem
  caches, although model-load time differed by only about 0.08 seconds.
- The transcripts were not byte-identical. CPU and Vulkan took different
  decoding fallback paths, and Vulkan performed more sampling runs
  (20,550 versus 17,072).
- Treat the 6.138× result as evidence that Vulkan materially accelerates this
  setup, not as a promised speedup for other GPUs, models, audio, drivers, or
  whisper.cpp releases.

For a new machine, repeat the benchmark with the same decoded WAV, model,
whisper.cpp version, arguments, and output format. Record the runtime backend
markers and compare both wall time and transcript quality.
