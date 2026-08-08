# Scene plan

Read before writing `scenes.md`. The plan is the blueprint — implementation
should be faithful transcription, not invention.

## Narrative arc

Every good explainer runs **comfort → surprise → awe → resolution**.

1. Start with something the viewer already understands.
2. Reveal complexity until their intuition breaks.
3. Deliver the insight that makes it click.
4. Close on the larger implication.

A video that opens on complexity has no arc. A video that never breaks the
viewer's intuition has no reason to exist.

## Concept selection

Score candidates on four axes before committing:

- **Visual punch (1–10)** — is there an animation moment that stops a scroll?
- **Academic depth** — is there real math, CS, or science underneath?
- **Virality** — would someone share it? Does it overturn an assumption?
- **Accessibility** — can a non-expert follow it and feel the insight?

The strongest concepts share traits: a number or image that creates awe,
progressive revelation, a viewer intuition that turns out to be wrong, a
connection to something the viewer already cares about, and an "aha" that can be
*shown* rather than told.

Avoid: purely verbal ideas, anything needing twenty minutes of setup before the
payoff, and topics whose visual would be "text appearing on screen."

## Storytelling principles

- **Show, don't tell** — every concept needs a visual representation.
- **Progressive revelation** — build complexity gradually.
- **Visual continuity** — transform objects rather than replacing them.
- **Pause for insight** — leave time to absorb a key moment.
- **Pose questions** — create curiosity before the answer.
- **Celebrate insight** — make the "aha" feel earned.
- **Connect representations** — show one concept several ways.
- **Zoom out for scale** — for dramatic size differences use
  `MovingCameraScene` with progressive zoom-out rather than side-by-side bars.
  Start close on the small value; zoom out to reveal each larger one until the
  earlier values shrink to nothing.

## Narration tone

Conversational, as if explaining something interesting over dinner.

- Slow down at reveals; let them land.
- Sell wonder, not fear: "Isn't it amazing that…"
- No jargon. Say "combinations", not "combinatorics".
- Acknowledge difficulty: "This might seem strange at first…"
- Use "you" and "your".
- Short sentences at the emphatic moments.

**Never read on-screen text.** If a number, formula, or label is visible, the
narration explains its *meaning*. The viewer has eyes. Say "that is already more
than every grain of sand on Earth" while the number is on screen — not "ten to
the eighteenth". Narration and visuals complement; they must not duplicate.

## `scenes.md` format

```markdown
# [Video Title]

## Overview
- **Topic**:
- **Hook**: [the opening question or mystery]
- **Target Audience**: [assumed background]
- **Estimated Length**:
- **Key Insight**: [the aha moment]
- **Branding**: [educational / soft CTA / product-forward]

## Narrative Arc
[2–3 sentences describing the emotional journey]

---

## Scene 1: [Name]
**Duration**: ~X seconds
**Purpose**: [what this scene accomplishes in the narrative]

### Visual Elements
- [mobjects, animations, camera movements]

### Content
[what happens, what is shown, how it transitions]

### Narration Notes
[key points, tone, pacing]

### Technical Notes
- [specific Manim classes, tricky implementations, known pitfalls]

---

## Color Palette
| Purpose | Hex | Notes |

## Mathematical Content
[every equation that needs rendering, as LaTeX]

## Transitions & Flow
[how each scene flows into the next]

## Implementation Order
[which scenes to build first, and why]
```

## Scope questions

Ask before composing, adapting as answers arrive rather than firing all at once:

- **Audience** — general public, technical, or domain expert?
- **Length** — short (3–5 min), medium (6–10), or long (12–18)?
- **Branding** — purely educational, soft CTA at the end, or product-forward?
- **Brand guidelines** — specific colors, fonts, or visual identity? Hex codes?

## Review the pair together

`scenes.md` and `narration_draft.md` are reviewed as one artifact, in two
passes:

1. **Story** — structure, coherence, engagement. Does the arc hold? Does each
   scene earn its duration?
2. **Execution** — is every number correct? Does the narration duplicate any
   on-screen text? Does each scene's narration fit its stated duration at
   roughly 150 words per minute?

Mathematical accuracy is checked here, not later. A number that does not compute
is a retraction after publication.
