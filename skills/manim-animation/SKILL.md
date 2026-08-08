---
name: manim-animation
description: Produce 3Blue1Brown-style explainer animations with ManimCE — brainstorm concepts from a domain or codebase, compose a scene plan, write scene code, render previews, QA the frames, generate ElevenLabs narration, and assemble a final 1080p video with synced audio. Use when asked for an animated explainer, a math or algorithm visualization, a concept video, or a Manim scene. Not for screen recordings of real software — use video-director for those.
compatibility: Requires ManimCE, LaTeX, ffmpeg, and uv. Narration requires an ElevenLabs API key. A devenv.nix providing the toolchain is in assets/.
metadata:
  status: experimental
  converted-from: deepwork job manim_video_producer v1.4.0
---

# Manim animation

Turn an idea into an animated explainer: concept → scene plan → ManimCE code →
preview → narration → final render. The pipeline is deliberately gated so the
expensive and irreversible steps happen last.

Supporting documents, read only when you reach that stage:

- `references/scene-plan.md` — storytelling arc, the `scenes.md` format, narration tone.
- `references/manim-code.md` — ManimCE pitfalls, layout, contrast, zoom, and scene-ending rules.
- `references/assembly.md` — ffmpeg merge and concatenation, and the two flags that silently corrupt audio.
- `assets/` — `devenv.nix`, `config.py`, and `render.sh` starting points.

## Default decisions

**Render a preview before you generate a single second of narration.** TTS costs
money and the script is written against visuals that may still change. The
ordering — preview, then visual QA, then narration — exists so you never pay to
narrate a scene you are about to rewrite.

**Never use `-shortest` when muxing narration onto a scene.** It clips the audio
mid-word. And never concatenate scenes with the file-based `concat` demuxer; it
glitches at every boundary. Use the `concat` *filter*. See
`references/assembly.md` — these two mistakes are the ones that force a full
re-render.

**Animation duration ≥ narration duration, always.** A frozen final frame while
the voice finishes is fine. A blank screen while the voice keeps talking is not.

## Workflow

Each stage writes files into `manim/<video-slug>/`. Stop at every **gate** and
get a human decision before continuing.

1. **Brainstorm.** Explore the domain, codebase, or URL. Propose 3–5 concepts
   ranked by visual punch, academic depth, virality, and accessibility. Write
   `concepts.md`. A concept without a specific visual hook is not a concept.
   **Gate:** the user picks one.

2. **Compose.** Turn the chosen concept into `scenes.md` plus
   `narration_draft.md` — scene durations, visual elements, camera moves, color
   palette with hex codes, and per-scene narration notes. Read
   `references/scene-plan.md` first. Review the two documents together, as a
   pair: narration that duplicates on-screen text is the most common defect.
   **Gate:** the user approves the plan.

3. **Set up.** Create `manim/<video-slug>/`, copy `assets/devenv.nix`, and let
   direnv load it. Verify with `manim --version` and
   `python -c "from manim import *"`. Do not install anything globally.

4. **Implement.** One file per scene, importing shared colors and the `Txt()`
   helper from `config.py`. Read `references/manim-code.md` before writing
   code — it is a list of failures already paid for. Test-render each scene at
   low quality as you go, rather than at the end.

5. **Render preview.** `./render.sh l` for 480p15. Fast, cheap, disposable.

6. **Visual QA.** Extract frames and inspect them for text overlap, low
   contrast, off-screen content, and text that became illegible after a camera
   zoom. Write `qa_report.md`. Fix and re-render before proceeding.
   **Gate:** the user approves the visuals.

7. **Narrate.** Only now. Finalize `narration_draft.md` into
   `narration/full_script.md`, one sentence per line. Generate per-scene audio
   with the shared helper (see Narration below). Compare each audio duration
   against the **actual rendered video duration**, not the target in
   `scenes.md`.

8. **Post-render review.** With real timings in hand, check pacing and
   coherence across scenes. Fix the animation, not the audio, when a scene runs
   short.

9. **Final render.** `./render.sh h` for 1080p60, then mux and concatenate per
   `references/assembly.md`. Verify the result plays with audio.

## Narration

Do not hand-roll the ElevenLabs call and do not put the key in a command line.
Reuse the helper from the `video-director` skill, which sends the key through a
temporary curl config and normalizes the output:

```sh
~/.agents/skills/video-director/scripts/render-narration.sh \
  --provider elevenlabs \
  --script narration/scene01.txt \
  --output narration/scene01.wav \
  --voice-id "$ELEVENLABS_VOICE_ID" \
  --confirm-external
```

On this host the key is read from `/run/secrets/elevenlabs-api-key`. Get
explicit user approval before the first request — it is a paid external service
that receives the full script.

One sentence per non-empty line. Multi-sentence lines cause dropped sentences.

## Validation

- MUST render every scene without error at low quality before any narration is generated.
- MUST verify each scene's audio duration is less than or equal to its rendered video duration.
- MUST NOT use `-shortest`, and MUST NOT use the file-based concat demuxer.
- MUST keep the final visual on screen at scene end; no `FadeOut(ALL)` followed by `self.wait()`.
- SHOULD keep each scene file under 150 lines.
- SHOULD use `MathTex` for every mathematical expression, never Unicode superscripts in `Text`.

## Diagnostics

| symptom | likely cause | fix |
| --- | --- | --- |
| Letters misaligned or badly kerned | Default serif font hits a Pango bug | Use the `Txt()` helper from `config.py`, never bare `Text()` |
| Re-render produces identical output after changing `self.wait()` | Manim reused cached partial movie files | Delete `media/videos/<scene>/<quality>/partial_movie_files/` and re-render |
| `MathTex` fails or renders nothing | LaTeX not on PATH | Enter the devenv shell; do not hardcode a TeX path |
| Audio cuts off mid-word in the final video | `-shortest` was used when muxing | Remove it; let ffmpeg extend to the longer stream |
| Clicks or glitches at scene boundaries | File-based concat demuxer | Re-concatenate with the `concat` filter |
| A scene has no audio and breaks concatenation | Silent scenes need an explicit track | Add an `anullsrc` audio track before concatenating |
| Labels unreadable after a zoom-out | Text scaled with the camera frame | Camera-attached overlay text, or re-add labels at the new scale |
| Elements overlap after new content appears | Old content never removed | `FadeOut` or `self.remove()` the old elements first |

## Scope

This skill synthesizes animation from scratch. For a demo of software that
actually exists — terminal, browser, or desktop capture — use `video-director`
instead; a real WORM refusal or a real test failure is evidence, and an
animation of one is not. For cutting, subtitling, or transcribing existing
footage, use `media-editor`.
