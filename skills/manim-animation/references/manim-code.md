# ManimCE implementation

Read before writing scene code. Everything here is a failure someone already
paid for.

## API pitfalls

| Problem | Wrong | Right |
| --- | --- | --- |
| Text kerning | `Text("hello")` | `Txt("hello")` — the default serif font hits a Pango bug |
| Superscripts | `Text("10⁵²⁴")` | `MathTex(r"10^{524}")` |
| Counter animation | `Integer(42)` | `Txt("42")` plus `Transform()` — `Integer` needs LaTeX |
| Multiple fade-in | `FadeIn(a, b, c)` | `FadeIn(VGroup(a, b, c))` — it takes one positional arg |
| Table rows | `table.get_row(2)` | Build manually with `VGroup` + `Rectangle` + `Text`; the API varies by version |
| Camera zoom | `Scene` | `MovingCameraScene` and `self.camera.frame` |

`MathTex` needs LaTeX on PATH. Enter the devenv shell rather than exporting a
distribution-specific path.

## The caching trap

Manim caches partial movie files. Edit a `self.wait()` duration, re-render, and
you can get byte-identical output. Either render with `--disable_caching` (what
the bundled `render.sh` does) or delete
`media/videos/<scene>/<quality>/partial_movie_files/` before re-rendering.

This one costs an hour of debugging a change that did apply.

## Layout and overflow

The default Manim frame is only about 14 units wide.

- **Anticipate growth.** If elements are added dynamically — columns, dots, list
  items — position the initial ones to leave room, and shift existing content
  before adding.
- **Scale conservatively.** Use 0.45 or smaller for tables and grids that grow.
- **Fixed positions for fixed things.** Titles and labels should use absolute
  positions (`.move_to(UP * 2.5)`), not `.next_to(table, UP)`, when the
  reference object will move or resize.
- **Check the final state.** Verify where everything sits at the *end* of the
  scene, not the beginning.
- **Clear before adding.** New elements do not visually override old ones — they
  overlap. `FadeOut` or `self.remove()` first.
- **Check every placement for collisions.** The classic one: a summary box at
  the bottom of the frame landing on top of nodes or labels already there.

## Color contrast

- High contrast is mandatory. Prefer bright, saturated colors — white, gold,
  electric blue — for anything that carries meaning.
- Never use a dim gray or a low-opacity element for content the viewer must
  read. Those are for decoration only.
- **Zoom-out contrast:** colors that look fine at normal scale vanish when the
  camera pulls back. Imagine the element at one fifth its size — still visible?
- Prefer pairs with strong separation (gold on dark purple, white on dark blue).
  Avoid similar hues (light gray on medium gray).

## Text during camera zoom

With `MovingCameraScene` and more than a 3× frame-width change:

- Labels below `font_size 20` are unreadable after even a 3× zoom-out.
- **Option A** — camera-attached overlay text that holds a fixed screen size.
- **Option B** — `FadeOut` small labels before zooming, `FadeIn` replacements at
  the new scale.
- **Option C** — during zoomed-out segments use only `font_size 36+`.

Compute it: `zoom_factor = final_frame_width / initial_frame_width`. Any text
with `font_size < 20 * zoom_factor` will be illegible.

## Timing

- Add enough `self.wait()` calls to approximate the duration in `scenes.md`.
- Prefer a few long holds (2–3 s) at key moments over many short ones.
- **Target animation duration ≥ narration duration.** The narration step
  generates audio that must fit inside the scene. Slightly long is fine — the
  viewer sees the final visual while the voice finishes. Short is not — the
  viewer sees a blank screen while the voice keeps going.

## Scene endings

**Never end with `FadeOut(ALL)` followed by `self.wait()`.** That leaves a blank
screen while audio may still be playing.

- Keep the last meaningful visual on screen at scene end.
- If a scene must clear for narrative reasons, make the `FadeOut` the very last
  call — nothing after it.
- Preferred: `self.wait(2-3)` with the final visual displayed, then `FadeOut`.
- When unsure, leave more on screen. A held frame always beats a blank one.

## Code style

- Keep each scene under 150 lines.
- Descriptive variable names, not `a`, `b`, `c`.
- Comment the narrative purpose of each block: `# --- the big reveal ---`.
- Blank lines between narrative beats.
- Use `self.wait()` deliberately, with the longest pauses at the insights.

## Implementation discipline

Implement the plan; do not redesign it here. If an animation turns out to be
technically impossible, note it and build the closest working alternative — the
preview render is where the human evaluates and asks for changes.
