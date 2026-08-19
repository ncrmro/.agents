---
name: storyboard
description: Turn a narrative — a pitch deck, a product concept, a pre-CAD design — into a shot list of images, each with a defined subject, camera and source, edited from a real photograph wherever one exists and generated from a prompt tree only where none does. Use when a Slidev deck needs imagery, when mocking up hardware before CAD exists, when a set of scene images keeps drifting or ignoring its prompts, or when deciding what images a story needs at all.
---

# Storyboard

A story needs pictures before it needs good pictures. This skill owns the
layer above image generation: which shots exist, what each must prove, and
which of two pipelines makes it. The `generated-imagery` skill owns the
machinery below — prompt trees, content-addressed snapshots, provenance, the
review surface. Use both together.

## The split that decides everything

Prose is good at **identity** and bad at **scenes**.

- Identity — what a thing *is*: dimensions, faces, materials, markings, its
  one interface. Fragments hold this well. One file owns each fact; every
  scene references it.
- Scene — composition, light, camera, scale relationships. This is where
  prompt-only generation burns afternoons: a 23 kB resolved prompt still
  drew the wrong lighting, floated the wrong limbs, and grabbed the wrong
  part with a robot arm. A real photograph fixes all of it for free.

So the first question per shot is never "what do I write" — it is **"does a
photograph of this setting exist?"** Agency archives (NASA, ESA, JAXA),
manufacturer press photos, and your own product shots cover more settings
than expected.

## Shot list first

One table before any prompt. Per row: beat, image id, **the one thing this
picture must prove** (one sentence), source photograph or `generated`, and
aspect ratio. A picture that proves two things proves neither; split it. A
beat no picture can prove yet (a UI that doesn't exist) gets a screenshot of
the real thing later, not an illustration of it now — a screenshot of
something real is worth more than a render of something imagined.

## Pipeline A — photo edit (default when a photo exists)

1. Ingest the photograph as an evidence package: original file, provenance,
   licence, SHA-256, and a written description of what it shows and does not
   establish. Verify agency imagery is actually that agency's work.
2. The prompt is **only the additions**. Refer to the image as "the
   photograph". State what to add and how it sits in the scene. Close with
   what stays: "Everything else stays as the photograph has it: the framing,
   the lighting, the colours."
3. Never reference delivery mechanics. Not "the attached photograph", not
   "the image above", not a frame number, not "edit". The web model applies
   pasted text to whatever image accompanies it; which file to attach is
   operator instruction and lives in the shot table.
4. Things the photograph **already shows** enter as shorts: two to four
   sentences of identification plus only the failure rules an edit can still
   trip. The thing being **painted in** keeps its full identity fragment —
   it is the only content the model must invent.
5. Global style/design-language fragments stay out of edit prompts. The
   photograph is the design authority.

## Pipeline B — pure generation (no photo exists)

For the object itself — the reference views, the hero shot, the pre-CAD
mockup. Follow `generated-imagery` for tree mechanics. Storyboard-level
rules:

- One identity file per object: every dimension, each face and what it
  carries, material and colour with hex, the markings, verbatim.
- One **view file per shot family**, so a prompt carries only what its
  camera can see: `thing.three-quarter.md`, `thing.detail.md`,
  `thing.distant.md`. The distant view explicitly omits sub-resolvable
  detail ("at this size a nozzle is a texture the model invents — leave it
  off"). Every scale of view needs this or detail drifts in.
- Scale claims must count the largest feature. "Small as a shoebox" is false
  if the deployed panels span five metres.

## Failure rules that transfer everywhere

Earned across ~10 generations each; they apply to both pipelines.

- **Silence fails, prohibition backfires.** Say what is wanted, with the
  number. Naming what you don't want gets you it: "no floating hands" draws
  floating hands, "the wings stand clear of the arm" draws the arm on a
  wing. State the positive fact — "one point of contact" — and stop.
- **Interiors described from outside.** Write what a closed mechanism looks
  like, never what works inside it, or you get a cutaway.
- **One term, one meaning.** A word the prompt never defines ("berthed") is
  a fact the model invents. Define it in place: "berthed means held".
- **A limb may leave the frame; it may not end inside it.**
- **Every edit re-renders.** Track prompt-vs-render staleness (provenance
  hashes); "the prompt isn't working" is usually "you are looking at
  yesterday's render".

## Pre-CAD mockups

The cheapest hardware mockup: identity file for the object (dimensions per
face, materials, one marking) + a three-quarter view + a detail view + one
in-context shot for scale (on a desk, in a hand, beside the machine it
serves). If an analogous product exists, pipeline A: photograph the
analogue or pull the manufacturer's press photo, and the prompt replaces the
analogue with your object. Iterate on the identity file, not the renders —
the file is what survives into the CAD brief.

## Slidev

One image per slide beat, mapped in the shot table. The deck stays
customer-facing: no prompt ids, no copy buttons, no tooling in slides — a
separate review surface owns prompts, provenance and labels. See the
`slidev-presentation` skill for deck mechanics.
