# The generation harness

## One call per variant

Run one backend call per variant, in parallel. Do not ask one call to produce N
variants: a single call correlates its own outputs, so the batch explores less
than N separate calls do, and one failure takes the whole batch with it.

Each call generates one image and exits. **Nothing reviews its own output.** Turn
the backend's self-review off. A separate pass does review, on the review
surface, with a human or a fresh-context agent looking at it.

Low reasoning effort is enough. The model chooses nothing during generation --
it reads a tree and calls an image tool -- so reasoning buys wall-clock rather
than pixels.

## Variant suffixes must not run out silently

Continue suffixes from whatever already exists, so a rerun never overwrites an
earlier batch.

A single-letter A-Z scheme exhausted itself on a well-iterated image. The script
found no free suffix, generated nothing at all, and reported success. Extend the
alphabet (A-Z then AA-ZZ) **and** fail loudly when the suffixes still run short.

## Record provenance per render

Append one line per render to a JSONL log, carrying at least:

| field | why |
| --- | --- |
| image | the file it describes |
| prompt | the content hash of the frozen tree |
| model, effort, tier | the settings, so two rounds are comparable |
| seconds, tokens | what the round cost |
| fragments | the run's own account of every file it read |
| saved, on_disk, error | whether a picture actually exists |

Without this you cannot say why one round looks worse than the last. The
`fragments` list is the one field that catches a tree which failed to resolve:
without it, a missing fragment shows up only in the picture, as a mystery.

## Structured output

A structured output schema makes each run append its own row rather than making
the script parse logs.

**A strict JSON Schema requires every property to be listed in `required`.** An
optional field is expressed as a nullable type, not as an absent requirement:

```json
"error": {
  "type": ["string", "null"],
  "description": "Why the image was not generated. Null when saved is true."
}
```

with `"error"` still present in `required`. Leaving it out of `required` is
rejected, and the rejection often arrives as a generation failure rather than as
a schema error.

## Declare the toolchain

Missing local tools cost silent time. One generator fell through a chain of image
utilities on every single render before it found one that existed on the machine.
Declare the tools the harness needs in the project's environment definition, and
check for them once at the start rather than per render.

## The review surface

A local page, served from the image set directory. What it must have:

- **Candidates grouped by image**, one tab or section per prompt id.
- **A latest-generation filter, on by default.** Cluster renders into
  generations by their timestamps, with a gap of a few minutes separating one
  batch from the next. A reviewer looking at forty candidates judges none of
  them.
- **The resolved prompt beside the render**, showing every file in the tree with
  its byte count and a rough token count. Sticky on a wide screen, so reading the
  prompt does not scroll the picture away. Show a missing reference in place as
  "(not found)" -- that is reviewable evidence.
- **The reference imagery** for whatever the prompt names, below the prompt.
  Evidence is consulted after a verdict forms, not scrolled past to reach the
  thing being judged.
- **Per-render provenance on the card**: model, effort, tier, duration, tokens,
  how many files the run read, and a link to the prompt snapshot.
- **A verdict and a note per candidate**, appended to a feedback log. Keep each
  card self-contained: judging two renders at once is how a defect in the second
  gets excused by the first.
- **A stale marker** on any group whose subject description has moved on since
  the render, so nobody spends judgement on geometry already known to be wrong.

One more query earns its place: given a fragment, which images does it feed?
Editing a shared fragment should offer to requeue exactly those images and no
others.

Keep the whole output directory out of version control. Renders, snapshots,
feedback and provenance all live there.
