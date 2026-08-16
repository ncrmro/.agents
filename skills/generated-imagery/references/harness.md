# The generation harness

## Do in the script what the script can do

The prompt tree exists to make generation reproducible. Resolving it inside the
non-deterministic part of the system gives that up.

**Anything you delegate to the agent's judgement is not reproducible, and
anything you ask the agent to report about its own behaviour is not evidence.**

So the harness resolves the tree, freezes it, inlines the text, and empties the
working directory. The agent's only job is the one thing a script cannot do:
make the picture. `references/prompt-tree.md` carries the audit that forced this,
and the four steps in detail.

Three consequences for the harness:

- **Pass finished text, not references.** Whether an agent reads the right files,
  no files, or every file in the directory varies by model and by run, and both
  failures are silent.
- **Give each run an empty working directory.** Containment beats instruction: a
  run that cannot reach the image set cannot borrow from another image.
- **Never take provenance from the agent.** The fragment list comes from the
  frozen manifest. Ask the agent only about things you can check yourself, such
  as whether a file exists on disk.

## One call per variant

Run one backend call per variant, in parallel. Do not ask one call to produce N
variants: a single call correlates its own outputs, so the batch explores less
than N separate calls do, and one failure takes the whole batch with it.

Each call generates one image and exits. **Nothing reviews its own output.** Turn
the backend's self-review off. A separate pass does review, on the review
surface, with a human or a fresh-context agent looking at it.

Low reasoning effort is enough. The model chooses nothing during generation --
it receives finished text and calls an image tool -- so reasoning buys wall-clock
rather than pixels.

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
| fragments | every file in the tree, **taken from the frozen manifest** |
| saved, on_disk, error | whether a picture actually exists |

Without this you cannot say why one round looks worse than the last.

Take `fragments` from the snapshot manifest, never from the agent. An earlier
version of this harness asked the run to report the files it had read, and the
report was correct in exactly the case that mattered: a run that had opened
nothing still listed the complete tree, because it was reporting the tree it was
meant to load. A field that is right when things go right and also right when
they go wrong measures nothing.

## Structured output

A structured output schema makes each run append its own row rather than making
the script parse logs.

**Ask the run only what you can verify.** Whether a file exists at a path is
checkable, so `saved` and `path` are worth having beside the script's own
`on_disk` check -- a disagreement between them is itself a finding. What the run
read, thought, or intended is not checkable, so it does not belong in the schema.

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
  how many files the frozen tree held, and a link to the prompt snapshot. Link
  the snapshot's `resolved.txt` too: that is the text the render was actually
  made from, and it is the artifact to diff when a look regresses.
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
