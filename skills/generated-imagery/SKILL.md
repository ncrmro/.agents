---
name: generated-imagery
description: Produce a set of generated images that look like one world — a prompt tree of shared fragments, content-addressed snapshots so a regression can be diffed rather than guessed at, a parallel generation harness with per-render provenance, and a review surface. Use when generating illustrations, renders, or concept imagery for a deck, site, game, or product; when images in a set drift apart between runs; when a render comes back looking like smooth plastic, at the wrong scale, or missing something the prompt asked for; when an image asserts something that contradicts the text beside it; or when setting up image generation for a project.
---

# Generated imagery

A set of images that must look like one world — a deck, a game's concept art, a
product line, a book's illustrations, a site's assets. Consistency across the set
matters more than any single image, so the unit of work is a **prompt tree**, not
a prompt. The craft rules below improve one image too.

| script (in `assets/`) | does |
| --- | --- |
| `snapshot-prompt.py <id>` | Resolves the tree, freezes it and the resolved text under a content hash, prints the hash. |
| `snapshot-prompt.py --resolve <id>` | Prints the whole tree as one document, ready to send. Writes nothing. |
| `generate.sh <id> <count>` | Snapshots, then runs one backend call per variant in parallel, each with the resolved text inline in its own empty directory, and appends provenance. |
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

## An image set is a set of claims

An image asserts things about the world. An assertion the project does not hold
is a defect, even when the image is beautiful. Give an image set the same factual
discipline you give prose.

**Resolving an ambiguity invents a fact.** Filling a silence in a prompt is not a
neutral edit. It commits the project to an assertion, and a physically plausible
answer is not necessarily the true one. That difference is invisible from inside
the prompt tree, so reviewers who reason only about physics endorse the error.

Before you fill a silence about how something works, read what the surrounding
material already claims: the captions, the body copy, the design notes. Then
record the constraint in the set's agent notes, not only in the prompt you fixed.
A prompt-local fix is forgotten by the next agent, who meets the same silence and
resolves it the same wrong way.

**Give the agent notes a "what this subject never does" section.** A negative
constraint is the wrong tool inside a prompt, where it leaves every alternative
open. It is the right tool in the notes that govern how prompts get written,
because there the reader is an agent choosing what to write rather than a model
choosing what to draw. Name the tempting wrong branch and say why it is wrong. A
constraint that only states the truth does not stop the repeat.

## The tree

```
<image set>/
  AGENTS.md            how prompts get written here, and what the subject never does
  design.md            the visual language for the whole set
  prompts/<id>.md      one file per image. The whole file is the prompt.
  fragments/<name>.md  one file per subject, one per reusable component
  evidence/<name>.md   one record per real thing a fragment depicts
  out/                 renders, snapshots, provenance. Not committed.
```

Write a reference as `@<relative-path>.md`, inside the sentence that needs it.
The scripts resolve them recursively: a prompt names a subject, the subject names
its components. A fix to a shared fact then reaches every image that shows it,
instead of being retyped per image and drifting apart.

**A reference is an instruction to your tooling, not to the generating agent.**
Resolve the tree with the script and send the model finished text. Never hand it
an `@` reference and trust it to follow the trail — see below.

**Separate the part from its placement.** A component fragment carries its own
dimensions and form, and never reaches for a subject to size itself against. The
subject that carries it says where it goes and how many. The scene prompt is
where they meet.

## Do in the script what the script can do

**Anything you delegate to the agent's judgement is not reproducible, and
anything you ask the agent to report about its own behaviour is not evidence.**

The prompt tree exists to make generation deterministic. Resolving it inside the
non-deterministic part gives that up. Where a step can be done by a script, do it
in the script. The agent's only job is the one thing a script cannot do.

Reference resolution is the case that proves it. An audit of one nine-image run,
comparing what each generation was asked to read against what it executed, found
the delegation failing in both directions and silently in both:

- One run read **only the scene file**, and drew a subject it had no dimensions,
  materials or palette for. The picture looked plausible and was wrong throughout.
- Several runs read **every fragment in the directory** — 26 files where the tree
  was 3 — and pulled in components belonging to other images.
- One model resolved the tree correctly; another did not; the same model varied
  between runs. **Reference resolution is emergent agent behaviour, not a
  platform guarantee.**
- The agent's own report of which fragments it read listed the correct tree in
  the failing case. **Self-reported provenance is worthless** — it reports the
  tree the agent was supposed to load, not the one it did.

So the harness, and the shipped scripts, do this instead:

1. **Resolve the tree in the script.** `--resolve` prints the whole tree as one
   document: shared context first, the scene prompt last, with each `@path.md`
   token rewritten to the bare name so the inlined sentences still read.
2. **Pass that text inline**, between markers, and say plainly that the
   description is complete and there is nothing to read.
3. **Run each generation in its own empty scratch directory**, then move the
   render out. With the set unreachable, a run cannot wander into another image's
   fragments. This is containment, not tidiness.
4. **Take the fragment list from the frozen manifest**, never from the agent. Ask
   the agent only what you can check yourself.

There is no budget argument against inlining: a whole resolved tree of around
14 kB costs nothing measurable against the harness's own system prompt.

## Workflow

1. Write `design.md` — palette, light, lens and framing, materials, and one
   rendering paragraph.
2. Write a fragment per subject and per reusable component. Give each one a
   material sentence and a scale anchor.
3. Write one prompt per image using the four sections below, referencing the
   design file and the subjects.
4. Run `check-prompts.sh`. Fix what it flags, or decide the hit is correct prose.
5. Read `snapshot-prompt.py --resolve <id>` once. It is what the model will
   receive, and a broken reference or a missing fragment shows up here rather
   than in a picture an hour later.
6. Run `generate.sh <id> 3`. It snapshots and resolves the tree first.
7. Review on the local surface: latest generation only, resolved prompt beside
   the render, provenance on the card.
8. Fix the fragment, not the image. Regenerate everything that fragment feeds.

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
| A render ignores everything its fragments specify — wrong proportions, no palette, invented scenery, yet plausible in itself | the run never opened the referenced files; resolution was left to the agent, which read only the scene file | resolve the tree in the script and pass the whole text inline. Do not trust the run's own report of what it read — it lists the tree it was meant to load |
| A render contains an object no fragment in its tree mentions | the run read every file in the directory instead of the tree, and borrowed from another image | pass finished text, and generate in an empty scratch directory so the set is unreachable |
| Surfaces look smooth, moulded, plastic — a product render | the fragment carries dimensions and no material noun | add a material sentence to every surface |
| Still plastic after adding material words | camera square-on and light flat, so the texture is geometrically invisible | move the camera off square and rake the key light |
| A component renders at the wrong size | a figure with no familiar-object anchor | keep the figure, add the anchor |
| Two parts both wrong, but consistent with each other | the anchor pointed at another part of the same subject | anchor to something outside the subject |
| A fitting or attachment point moves between renders | the prompt named neither the fitting nor the surface it sits on | name the fitting in use, name its face, and say where the camera stands relative to both |
| The image contradicts the text beside it, or asserts something untrue about how the subject works | a silence in the prompt was filled with a plausible invention, which committed the project to a claim it does not hold | check the claim against the project's own material before you fill the silence, then record the constraint in the set's agent notes |
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
  the file list **from the frozen manifest** — or two rounds cannot be compared.
- **Ask the run only what you can verify.** Whether a file exists at a path is
  checkable, so a disagreement between the run's `saved` and the script's own
  on-disk check is a finding. What the run read or intended is not checkable, so
  it does not belong in the output schema.
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
