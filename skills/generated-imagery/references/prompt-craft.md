# Prompt craft

Every rule here comes from a render that came back wrong. The failure is part of
the rule. A rule with its story gets followed; a bare rule gets argued with.

## The rule the others are instances of

**A prompt fails by silence, not by permission.**

Its usual failure is not that it allowed something unwanted. Its failure is that
it never said what was wanted, so the model filled the gap with its default.

- "No thin strips" leaves every wrong width available.
- "Each wing is 1,200 by 2,400 mm" leaves one right one.

Write the second. A prohibition earns its place only after a render actually
fails, and then it names that one failure and not a class of them.

## Resolving an ambiguity invents a fact

The rule above tells you to fill the silences. This one tells you what filling a
silence costs.

An image asserts things about the world. An assertion the project does not hold
is a defect, even when the image is beautiful. So filling a silence is never a
neutral edit: it commits the project to a claim.

A prompt described an object being worked on, but never said how the object was
held. The renders put the attachment point somewhere different every time. The
fix looked obvious: name one attachment and be done. The attachment chosen was
physically sound and drew consistently. It was also operationally false, because
the project's own argument was that this class of object never attaches to the
thing it services. The image then contradicted the text beside it. Two
independent reviewers had endorsed the fix. Both were reasoning about physics,
and neither was checking the claim against the project's stated position.

A physically plausible answer is not necessarily the true one, and the difference
is invisible from inside the prompt tree. So:

1. **Read the surrounding material before you fill the silence.** Grep the
   captions, the body copy, the design notes and the argument the images serve.
   The claim you are about to make is often already made, or already denied.
2. **Record the constraint where prompts get written**, not only in the prompt
   you fixed. A prompt-local fix is forgotten by the next agent, who meets the
   same silence and resolves it the same wrong way.

## Negative constraints belong in the notes, not in the prompt

This is the one place a prohibition is the right tool, and the distinction is
worth stating outright.

- **Inside a prompt**, a prohibition fails, because the reader is a model
  choosing what to draw and every alternative stays open. State the fact.
- **Inside the set's agent notes**, a prohibition works, because the reader is an
  agent choosing what to write, and a written rule closes a decision.

Give the notes a section saying what the subject **never** does. Name the
tempting wrong branch and say why it is wrong. A constraint that only states the
truth does not prevent the repeat; a constraint that names the attractive error
does.

## Name a material, not only a size

A fragment whose only content is dimensions renders as product visualisation:
smooth, moulded, plastic. Figures say how big a thing is. They never say what a
surface is made of, and a model with no material noun defaults to
injection-moulded white.

One set had a single component fragment that carried a material sentence while
every other fragment carried only dimensions. That component was the one thing
in the frame that still read as real hardware.

Give every surface a material sentence: what it is, how it is fastened, and what
it does under a raking light.

> Quilted bone-white blanket, matte, over a machined aluminium frame. The
> quilting runs in squares about 150 mm across. The blanket wrinkles between the
> stitch lines and pulls tight at each fastener. Fasteners run at 200 mm spacing
> along every frame line.

## Pair the material rule with the camera

Texture is only visible when the key light rakes across it and the camera sits
off square. Material words plus flat light plus a square-on camera still gives
you plastic. The two rules are one rule.

A prompt asking for a face square to camera under flat light rendered a quilted,
blanketed, fastened surface as smooth plastic. No material word anywhere in the
tree survived that geometry.

## Give exact figures, then anchor them to a familiar object

A figure fixes a dimension. It does not say how big a thing feels, because a
model has no body and a millimetre figure is only a token to it. Naming an
everyday object of about that size supplies the scale the number cannot.

Write both. The number rules; the object calibrates it.

> The body is 1,170 mm long, 865 mm across and 550 mm deep, about the size of a
> large domestic appliance.
>
> The cluster is a machined block 280 x 180 x 150 mm, about the size of a loaf
> of bread.

Anchor a component to a household object, and a whole subject to a piece of
furniture, an appliance or a vehicle.

This is the one place a comparison belongs. A comparison standing *instead of* a
figure -- "roughly appliance-sized", "no thicker than the engine bell" -- is the
original silence failure and stays banned, because it leaves every wrong size
available.

Give every component fragment an anchor. A component is where scale errors
start, and a render that gets one component wrong drags the subject carrying it
wrong with it.

## An anchor must reach outside the subject

Do not anchor one part of a subject to another part of the same subject. A model
drawing both of them wrong keeps them wrong in proportion to each other, so the
image looks internally consistent while being the wrong size throughout.

## Say a thing once

One fact beats one fact plus two prohibitions.

- Fact: "Off-white, #E4E1D6, matte."
- One fact and two prohibitions: "Off-white, never bright white and never
  metallic."

## Put a reference inside the sentence that needs it

Write "the display shows the delivery view per @../fragments/delivery-ui.md"
inside the paragraph about the display. One mention, at the point of use.

A trailing reference list at the end of a file means nothing ties the referenced
description to the thing it describes at the moment the model is drawing it. The
file also stops reading as a prompt and starts reading as a manifest.

## Never hand the model a choice

An "or", a "may", an "either" produces a different answer every run, and across
a set that reads as inconsistency. Pick one. Make the alternative a separate
prompt.

## One text string per object

Image models degrade fast with each additional string of text. If an object
needs an identifier and a name, make them one string.

## Drop decorative markup

No bold, no italics, no backticks. A model reads them as characters and they
carry no meaning it can act on.

Keep only markup that carries structure: the section headings, and a fence
around a diagram.

This rule governs prompts and fragments. It does not govern the notes, plans and
skill files a human reads.

## Write prose, not a specification sheet

Full sentences carrying figures inside them -- "the pad is 250 mm across, flush
at the centre of the face" -- rather than a bulleted `diameter: 250mm`. The four
section headings group prose and nothing else. `## Camera` is followed by
sentences, not by `lens: 85mm`.

## Keep provenance out of the prompt

Where a figure came from, which vendor ruled it, what shipped before and why the
choice follows it: none of that is renderable. A model cannot draw "per the
vendor datasheet". State the figure in the prompt, and put the reasoning in the
evidence record, where the person answering a question will look.

## Spend the context budget deliberately, but do not optimise it

Every fragment is read in full on every generation, so a sentence nobody acts on
buries the one they would have.

Measure before you trim. In one set the whole resolved tree ran 3 to 14 kB
against a harness system prompt many times that size, so cutting fragments saved
nothing at all. Spend the budget on precision, not on brevity.

## When prose runs out

A feature that stays the wrong proportion across many attempts, after an exact
figure, an added relation to a neighbouring part, and an outside scale anchor,
is telling you that prose has run out.

Pass a reference image as an input instead. Record this honestly in the notes:
it is a real limit of text prompting, and the fix is a different mechanism
rather than another rewrite.
