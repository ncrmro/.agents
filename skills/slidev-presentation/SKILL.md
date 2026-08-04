---
name: slidev-presentation
description: Builds, revises, previews, and exports Slidev presentations from briefs, outlines, documents, or existing slide decks. Use when an agent must create `slides.md`, design a clear presentation arc, add visual assets and speaker notes, apply Slidev layouts or components, or validate a Slidev deck in a browser and exported PDF.
---

# Slidev presentation

Build a presentation as a visual argument, not as a document split across slides. Start with the audience and the change that the talk must cause. Then author and verify the Slidev deck.

Load supporting docs only when needed:

- `references/deck-template.md` — use for a new `slides.md` file.
- `references/review-checklist.md` — use before final delivery.

## Default decision

Make one claim per slide. Let the speaker notes hold the explanation.

Do not fill slides with paragraphs, repeated cards, or decorative interface panels. Prefer a strong title, one visual, and one short statement. Use empty space as part of the layout.

## Workflow

1. Inspect the task, source files, repository rules, and existing Slidev setup.
2. Identify the audience, duration, venue, purpose, and required output.
3. State the deck thesis in one sentence.
4. Draft a slide table before you write Slidev markup.
5. Assign one purpose to each slide.
6. Select a layout and a visual treatment for each slide.
7. Reuse the existing theme, components, and assets when they fit.
8. Create or revise `slides.md`.
9. Add speaker notes as the last HTML comment on each slide when the talk needs them.
10. Add click steps only when sequence helps the audience understand the claim.
11. Run the repository format and build commands.
12. Preview the deck in a browser.
13. Inspect the overview and representative slides at the target aspect ratio.
14. Export the required artifact and inspect it.
15. Apply `references/review-checklist.md`.

For a new deck, make this table first:

| slide | audience question | claim | visual | talk function |
| --- | --- | --- | --- | --- |
| 1 | Why should I listen? | The thesis | Hero image or type | Open |
| 2 | What is wrong now? | The problem | Evidence or contrast | Establish need |
| 3 | What changes? | The core idea | Diagram | Explain |
| N | What should I do? | The implication | Clear next action | Close |

## Structure the argument

Use a simple arc unless the material requires another form:

1. Open with the consequence.
2. Establish the current state.
3. Show the tension or evidence.
4. Explain the new model.
5. Prove it with examples or data.
6. End with a decision, action, or implication.

The title of each content slide SHOULD state its claim. A reader SHOULD understand the argument from the slide titles alone.

## Build the Slidev source

Use `slides.md` as the default entry file. Separate slides with `---`. Use the first YAML block as deck headmatter. Use later YAML blocks for slide settings.

Prefer native Markdown, theme layouts, UnoCSS utilities, and small Vue components. Add custom CSS or a new component only when repetition or a specific visual requires it.

Place local static assets in `public/`. Reference those assets from the deck with root paths such as `/images/model.svg`.

Use these Slidev features with restraint:

| feature | use |
| --- | --- |
| `layout` | Select a semantic slide structure. |
| `class` | Apply small slide-specific style changes. |
| `v-click` | Reveal a sequence that the speaker explains in order. |
| `<v-clicks>` | Reveal a short list in order. |
| Presenter notes | Keep evidence, transitions, and delivery cues off the slide. |
| Mermaid | Show a relationship or flow that prose cannot show clearly. |
| Vue component | Reuse a real visual pattern or add necessary interaction. |

Do not use click animation to repair a crowded slide. Split the slide.

## Visual assets

Use a visual only when it supports the slide claim.

- Search for source-backed charts, product images, or current facts when the claim needs evidence.
- Generate an original image when a concept needs a coherent illustration and no accurate source image exists.
- Preserve the source, license, and attribution for external assets.
- Prefer SVG for diagrams and logos. Prefer compressed raster files for photographs.
- Do not use a visual that contains unreadable text, fake interface details, or an unrelated decorative subject.

Use one visual language across the deck. Keep color, icon weight, diagram shape, type scale, and image treatment consistent.

## Local commands

Read the repository files before you select a command. Use the locked package manager and existing scripts. Do not install a global Slidev CLI.

| goal | preferred command shape |
| --- | --- |
| Start preview | `<package-manager> run dev` |
| Format source | `<package-manager> run format` or the repository format command |
| Build static deck | `<package-manager> run build` |
| Export deck | `<package-manager> run export` |
| Inspect CLI options | `<package-manager> exec slidev --help` |

Use the `dev-servers` skill before you start a local server when that skill is available.

Slidev export can require Playwright and a browser binary. Use the repository dependency and dev-shell workflow. Do not add a dependency until you confirm that the export command needs it.

## Validation

The deck MUST build without an error.

The required export MUST complete without an error.

Inspect the live deck or exported pages. Source review alone is not enough.

The deck MUST meet these checks:

- No element crosses the slide boundary.
- No text or diagram label is too small at presentation distance.
- Every visual has enough contrast.
- Code fits without horizontal clipping.
- Local assets resolve in preview and export.
- Click order matches the speaker notes.
- Slide numbers, titles, and export metadata are correct when required.
- The closing slide states the intended implication or action.

## Diagnostics

| symptom | likely cause | fix |
| --- | --- | --- |
| A local image works in Markdown preview but not Slidev | The path is relative to the Markdown file. | Move the file under `public/` and use a root path. |
| Export omits revealed content | The export uses the default final-slide behavior. | Check whether the output requires `--with-clicks`. |
| Export fails before Chromium starts | Playwright or its browser binary is absent. | Use the repository install or dev-shell procedure for the required browser. |
| Text or code clips in PDF but not in the browser | The export viewport, font, or late layout differs. | Inspect the exported page and reduce or reflow the content. |
| A slide needs many utility classes and absolute positions | The layout has no clear visual hierarchy. | Simplify the slide or create one focused component. |
| The deck feels repetitive | Every slide uses the same card grid or centered block. | Vary composition by purpose while you keep the visual system stable. |
| Presenter notes do not appear | The comment is not the last content on the slide. | Move the note comment to the end of that slide. |

## Current upstream references

- Slidev getting started: <https://sli.dev/guide/>
- Slidev syntax: <https://sli.dev/guide/syntax>
- Slidev animation: <https://sli.dev/guide/animations>
- Slidev user interface and presenter view: <https://sli.dev/guide/ui>

