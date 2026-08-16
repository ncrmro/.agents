# The prompt tree

## Layout

```
<image set>/
  AGENTS.md            how prompts get written here, and what the subject never does
  design.md            the visual language for the whole set
  prompts/<id>.md      one file per image. The whole file is the prompt.
  fragments/<name>.md  one file per subject, one per reusable component
  evidence/<name>.md   one record per real thing a fragment depicts
  out/                 renders, snapshots, provenance. Not committed.
```

A prompt references the design language and whichever subjects appear. A subject
references its own components. The scripts resolve the references recursively,
however many levels deep they go.

The point is propagation. A fix to a shared fact reaches every image that shows
it. The alternative -- retyping the fact into each prompt -- drifts apart within
a few rounds, and the drift is exactly what breaks a set.

## The reference syntax

Write `@<relative-path>.md` inside the sentence that needs it.

> A station arm per @../fragments/station-arm.md reaches in from one side.

The tooling matches `@` followed by a path ending in `.md`, anywhere on a line.
The snapshot script, the generation script and the review surface all resolve
the tree with that one pattern.

## Resolve the tree in the script, never in the agent

**A reference is an instruction to your tooling. It is not an instruction to the
image-generating agent.** Resolve the tree with the script, and send the model
finished text.

An audit of the generation transcripts of one nine-image run, comparing what each
run was asked to read against what it actually executed, found the delegation
failing in both directions, and silently in both:

- One run read **only the scene file**. It never opened the subject fragment or
  the shared design file, and drew a subject it had no dimensions, materials or
  palette for. The picture looked plausible and was wrong throughout: wrong
  proportions, invented scenery.
- Several runs read **every fragment in the directory** -- 26 files where the
  prompt's tree was 3 -- and pulled in components belonging to other images. That
  is how an unrelated piece of hardware appeared in a portrait of the subject
  alone.
- Runs on one model resolved the tree correctly, and even grepped recursively for
  nested references. Runs on another model did not. It varied between runs on the
  same model too. **Reference resolution is emergent agent behaviour, not a
  platform guarantee.**
- The agent's own structured report of which fragments it read listed the correct
  tree in the failing case. **Self-reported provenance is worthless.** It reports
  the tree the agent was supposed to load, not the one it did.

There is no context-budget argument for delegating the reads either. A whole
resolved tree of around 14 kB costs nothing measurable against the harness's own
system prompt.

### How the shipped scripts do it

1. **Resolve to one document.** `snapshot-prompt.py --resolve <id>` walks the
   references and prints the whole tree as one text. The referenced files come
   first and the scene prompt comes last, so the instruction nearest the
   generation is the one describing this image. Each `@path/name.md` token is
   rewritten to the bare `name`, so "a fixture per @some-fixture.md bolts to the
   plate" still reads as a sentence once the file is inlined beside it, under a
   section header carrying that same name.
2. **Pass the text inline**, between markers. Demand verbatim pass-through, and
   tell the model plainly that the text is complete and there is nothing to read.
   An agent left to its own bundled instructions summarises the prompt before the
   renderer ever sees it, so the wording must override that rule by name.
   `references/harness.md` carries the full wording and the A/B that verified it.

   ```
   Pass the text between the markers below to the image tool as the prompt,
   VERBATIM. Do not summarise it. Do not shorten it. Do not rewrite it. Do not
   select from it. Copy it through unchanged.
   ...
   The text is also complete. Do not read any file. Do not search for anything.
   There is nothing else to load.
   ```

3. **Run each generation in its own empty scratch directory** (`--cd` on the
   reference backend), then move the render out. With the image set unreachable,
   a run that decides to go looking finds nothing, so one image's fragments
   cannot leak into another image's render. This is containment, not tidiness.
4. **Take the fragment list from the frozen snapshot manifest**
   (`--fragments <hash>`), never from the agent. The output schema no longer asks
   the agent what it read, because the answer was not evidence. It asks only what
   the run did to the filesystem, which the script checks for itself.

The generation script reads the resolved text back out of the frozen snapshot
rather than resolving it a second time, so the bytes that were sent are exactly
the bytes on record.

## The agent notes

One file governing how prompts get written in this set. It is read by an agent,
not by an image model, so it uses ordinary prose and it may prohibit things.

It carries:

- The prose rules the set follows, and any rule it deliberately breaks.
- What the subject **is**: the one paragraph that says what a reader must take
  from every image of it.
- **What the subject never does.** Every claim the images must not make, each one
  naming the tempting wrong branch and why it is wrong. This section is what
  stops the next agent from resolving a silence the same wrong way; see the
  "Resolving an ambiguity invents a fact" section in `prompt-craft.md`.
- How the set treats a disagreement between its own figures and a vendor's.
- The commands: lint, snapshot, generate, review.

## The design language file

One file for the whole set, referenced by every prompt. Five sections carry it:

| Section | What it fixes |
| --- | --- |
| Palette | A short table of roles, hex values, and where each appears. Two accents at most; everything else is unsaturated. |
| Light | How many sources, how hard, what the shadows do, how much contrast. One source per frame. |
| Lens and framing | Focal length range, horizon, how much of the frame stays empty. |
| Materials | The one paragraph that keeps the set out of product-render territory. Fabricated, not moulded: seams, fasteners, tool marks, joints. |
| Rendering | A single paragraph restating the above as one continuous sentence run, for a backend that takes a style string. |

Add a Livery or Marks section if things in the set carry identifying text. Say
where the mark goes and how wide it is; the fragment for each subject then gives
its own size and placement.

## Separate the part from its placement

- A **component fragment** carries the component's own dimensions, form, surface
  and scale anchor. It never reaches for a subject to size itself against.
- A **subject fragment** says which components it carries, where they go, and
  how many.
- The **scene prompt** is where the two meet.

A shared-rule fragment is also useful: one file holding the rules that hold for
every instance of a component across every subject, referenced by each subject
that carries one.

Name a component fragment after the product, not after the job it happens to do
in one image. A filename says what a thing is.

## The four-section prompt template

```
## Scene     what is in frame, what is happening, and the tone of it
## Camera    where the camera stands, what lens, what angle
## Light     the key, its direction, and what it reveals
## Frame     the composition, what has to be readable, where the empty space is
```

All four, in that order, in every prompt. A short section is fine. A missing
section means the prompt left that decision to the model.

The headings also let a person comparing two prompts find the same thing in the
same place, and let an edit to the lighting happen without hunting through a
paragraph about content.

Put no title, no ID and no wrapper section inside a prompt file. The filename
carries the ID, and an index table carries everything else. Anything else in the
file is noise the model reads as instruction.

Keep an index of the set beside the prompts: one row per image, with its file,
where it is used, its aspect ratio, and one line on what it shows. Record there
which images are deliberately *not* generated, and why -- a screenshot of a real
thing, or an existing photograph, often beats an illustration.

## Content-addressed snapshots

Freeze the resolved tree under a content hash before every generation, and name
every render with that hash.

Without this you cannot answer "what did we actually ask for when this came out
wrong", because the files have moved on. With it, a regression is a diff.

`assets/snapshot-prompt.py` writes `out/prompts/<hash>/` with a flattened copy of
every file in the tree, a manifest of per-file hashes and byte counts, and
`resolved.txt` -- the exact bytes the generation receives. Freeze the resolved
document as well as its parts: a render is only reproducible from what was sent,
and the manifest is also the only trustworthy record of which files went into it.
An unchanged tree reuses its existing snapshot rather than duplicating it.

The payoff arrives at the first regression. One "it went plastic again" traced
to three separate sentence deletions across three files, each made by a
well-intentioned tidy-up pass, none of them a model change.

## The evidence layer

For a set that depicts real things, give every real component named in a prompt
a record of its own, carrying the published figures and the source they came
from.

- The fragment says what the thing **looks like**.
- The record says **why the numbers are what they are**.
- The fragment ends with a single line naming its record, so a reader moving
  from the picture to the evidence has one hop.

Discovering a real component while writing a prompt means writing its record in
the same pass. A figure that exists only inside a prompt cannot be checked and
will not survive the next project.

Keep reference imagery with the record, licence noted per file, and show it
beside the prompt on the review surface.

Where a set's figure and a vendor's figure disagree, keep both: the vendor figure
in the record, the set's figure in the fragment. Neither corrects the other. Say
which is which, and let a human choose. Do not narrow a fragment to a vendor
envelope because research surfaced one -- an illustration is not a procurement
drawing.

## The linter

`assets/check-prompts.sh` flags five habits that keep creeping back: provenance
inside a prompt, justification by precedent, a comparison standing where a figure
should be, a prohibition where a description would do, and a choice offered to
the model. It also reports a fragment nothing references.

The orphan check walks the whole tree, not only the top level, because a
fragment can be referenced from another fragment rather than from a prompt.

**A linter must evolve with its rules.** When one set adopted the scale-anchor
rule, the existing "vague comparison" check started flagging every good line. A
check that enforces a superseded rule trains its reader to ignore it, which costs
more than having no linter. Change the check in the same pass as the rule. The
shipped comparison check shows the pattern: it reads the whole line, so a
comparison sharing a line with a measurement passes as an anchor, and a
comparison standing alone is reported.
