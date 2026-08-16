---
name: generated-imagery
description: Produce a set of generated images that look like one world — a prompt tree of shared fragments, content-addressed snapshots so a regression can be diffed rather than guessed at, a parallel generation harness with per-render provenance, and a review surface. Use when generating illustrations, renders, or concept imagery for a deck, site, game, or product; when images in a set drift apart between runs; when a render comes back looking like smooth plastic, at the wrong scale, or missing something the prompt asked for; or when setting up image generation for a project.
---

# Generated imagery

A set of images that must look like one world — a deck, a game's concept art, a
product line, a book's illustrations, a site's assets. Consistency across the set
matters more than any single image, so the unit of work is a **prompt tree**, not
a prompt. The craft rules below improve one image too.

| script (in `assets/`) | does |
| --- | --- |
| `snapshot-prompt.py <id>` | Resolves the whole prompt tree, freezes it under a content hash, prints the hash. |
| `generate.sh <id> <count>` | Snapshots, then runs one backend call per variant in parallel, and appends provenance. |
| `check-prompts.sh` | Flags the prose habits an image model cannot act on, plus unreferenced fragments. |

All three take the image set directory from `IMAGESET_ROOT` (default: the current
directory). `generate.sh` isolates the backend into one marked function; the
shipped `codex exec` version is the reference implementation, swap it for another
tool.

Read a reference file only when the task reaches it:

- `references/prompt-craft.md` — every prose rule, with the render that earned it.
- `references/prompt-tree.md` — tree layout, reference syntax, snapshots, evidence records, the linter.
- `references/harness.md` — parallel generation, provenance, the review surface, the gotchas.

## The one trap that wastes an afternoon

**A prompt fails by silence, not by permission.**

Its usual failure is not that it allowed something unwanted. Its failure is that
it never said what was wanted, so the model filled the gap.

- "No thin strips" leaves every wrong width available.
- "Each wing is 1,200 by 2,400 mm" leaves one right one.

Every rule further down is an instance of this one. A prohibition earns its place
only after a render actually fails, and then it names that one failure.

The most expensive silence is **material**. A fragment whose only content is
dimensions renders as product visualisation: smooth, moulded, plastic. Figures
say how big; they never say what a surface is made of, and a model with no
material noun defaults to injection-moulded white. Give every surface a sentence
saying what it is, how it is fastened, and what it does under a raking light —
**and put the camera off square with the key light raking**, or the texture is
geometrically invisible and no material word survives.

## The tree

```
<image set>/
  design.md            the visual language for the whole set
  prompts/<id>.md      one file per image. The whole file is the prompt.
  fragments/<name>.md  one file per subject, one per reusable component
  evidence/<name>.md   one record per real thing a fragment depicts
  out/                 renders, snapshots, provenance. Not committed.
```

Write a reference as `@<relative-path>.md`, inside the sentence that needs it.
References resolve recursively: a prompt names a subject, the subject names its
components. A fix to a shared fact then reaches every image that shows it,
instead of being retyped per image and drifting apart.

**Separate the part from its placement.** A component fragment carries its own
dimensions and form, and never reaches for a subject to size itself against. The
subject that carries it says where it goes and how many. The scene prompt is
where they meet.

## Workflow

1. Write `design.md` — palette, light, lens and framing, materials, and one
   rendering paragraph.
2. Write a fragment per subject and per reusable component. Give each one a
   material sentence and a scale anchor.
3. Write one prompt per image using the four sections below, referencing the
   design file and the subjects.
4. Run `check-prompts.sh`. Fix what it flags, or decide the hit is correct prose.
5. Run `generate.sh <id> 3`. It snapshots the tree first.
6. Review on the local surface: latest generation only, prompt beside the render,
   provenance on the card.
7. Fix the fragment, not the image. Regenerate everything that fragment feeds.

## The four sections, in this order, in every prompt

```
## Scene     what is in frame, what is happening, and the tone of it
## Camera    where the camera stands, what lens, what angle
## Light     the key, its direction, and what it reveals
## Frame     the composition, what has to be readable, where the empty space is
```

A short section is fine. **A missing section means the prompt left that decision
to the model.** Camera and Light are separate headings because they failed
together: a prompt asking for a face square to camera under flat light rendered a
quilted, blanketed, fastened surface as smooth plastic, and no material word
anywhere in the tree survived that geometry.

The headings group prose and nothing else. `## Camera` is followed by sentences,
not by `lens: 85mm`.

## The rules, in one line each

| rule | because |
| --- | --- |
| Name a material, not only a size. | Dimensions alone render as moulded plastic. |
| Rake the light, move the camera off square. | Texture you cannot see is texture you did not buy. |
| Give the exact figure, then anchor it to a familiar object. | A model has no body; a millimetre is only a token. Write both — the number rules, the object calibrates. |
| Anchor outside the subject, never part-to-part. | Two parts drawn wrong together look consistent and are the wrong size throughout. |
| Say a thing once. | One fact beats one fact plus two prohibitions. |
| Put the reference inside the sentence that needs it. | A trailing reference list ties nothing to the thing being drawn. |
| Never hand the model a choice. | An "or" or a "may" answers differently every run, and across a set that reads as inconsistency. |
| One text string per object. | Image models degrade fast with each extra string. |
| Drop bold, italics and backticks. | A model reads them as characters. Keep headings and diagram fences. |
| Keep provenance out of the prompt. | A model cannot draw "per the vendor datasheet". Put it in the evidence record. |
| Spend the context budget deliberately, but measure before trimming. | A tree of a few kB against a much larger system prompt costs nothing; precision is what the budget is for. |

## Quick diagnostics

| symptom | cause | fix |
| --- | --- | --- |
| Surfaces look smooth, moulded, plastic — a product render | the fragment carries dimensions and no material noun | add a material sentence to every surface |
| Still plastic after adding material words | camera square-on and light flat, so the texture is geometrically invisible | move the camera off square and rake the key light |
| A component renders at the wrong size | a figure with no familiar-object anchor | keep the figure, add the anchor |
| Two parts both wrong, but consistent with each other | the anchor pointed at another part of the same subject | anchor to something outside the subject |
| A fitting or attachment point moves between renders | the prompt named neither the fitting nor the surface it sits on | name the fitting in use, name its face, and say where the camera stands relative to both |
| An arrangement renders differently every time | the prompt describes something physically impossible, so there is no right answer to converge on | check the rigging; one holder holds one thing at a time |
| A feature the prompt demands is not visible | it lives on a face the camera cannot see, so the prompt contradicts itself and the model resolves it by moving the feature | put the feature on more faces, or stop demanding it in this frame |
| The look regressed after a cleanup pass | a sentence was deleted, not a model changed | diff the frozen snapshot of the last good render against the current tree |
| The same object looks different in two images | it is described inline in each, not extracted to a shared fragment | extract it, route every mention through it |
| Garbled or duplicated text on an object | more than one text string in frame | make the identifier and the name one string |
| A feature stays the wrong proportion across many attempts, despite an exact figure, an added relation and an outside anchor | prose has run out | pass a reference image as an input; record the limit honestly rather than rewriting again |

## Harness gotchas

- **One call per variant, in parallel** — not one call producing several. Turn
  the model's self-review off; a separate pass reviews. Low reasoning effort is
  enough for generation.
- **Variant suffixes must not run out silently.** A single-letter A–Z scheme
  exhausted itself and the script reported success having generated nothing.
  Extend the alphabet, and fail loudly when suffixes run short.
- **Record provenance per render** — model, effort, tier, seconds, tokens, and
  the run's own list of files it read — or two rounds cannot be compared.
- **A strict JSON Schema needs every property in `required`.** Express an
  optional field as a nullable type, not as an absent requirement.
- **The orphan check must walk the whole tree**, because a fragment can be
  referenced from another fragment rather than from a prompt.
- **A linter must evolve with its rules.** When one set adopted the scale-anchor
  rule, the existing vague-comparison check began flagging every good line. A
  check enforcing a superseded rule trains its reader to ignore every check,
  which costs more than having no linter.
- **Declare the toolchain.** One generator fell through a chain of image
  utilities on every render before finding one that existed on the machine.
