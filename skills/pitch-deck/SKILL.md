---
name: pitch-deck
description: Builds investor, sales, and partnership decks whose every number carries an evidence class and whose every status claim carries a date. Use when an agent must write a pitch deck, a fundraising or investor deck, a sales or partnership deck, a demo-day or advisor brief, a data room summary, or the ask slide for a raise — and when a deck contains cost, market, traction, or roadmap figures that a reader can check.
---

# Pitch deck

Write the deck as an argument a hostile reader can check. A pitch fails on one unsourced number more often than on a weak story. This skill rules the numbers first, then writes the slides, then hands the deck to `slidev-presentation` to render and verify.

Supporting docs, loaded only when needed:

- `references/deck-structures.md` — the investor, sales, and partnership slide orders, and the question each slide answers.
- `references/honesty-checklist.md` — the final pass. Run it before you deliver.

## Default decision

Rule every number **before** you write a slide. Give each figure a class. Publish the class beside the figure.

| Class | Meaning |
| --- | --- |
| `public-vendor-price` | The vendor publishes this price. It is not a quote. |
| `vendor-spec` | The vendor publishes this capability in a datasheet. |
| `calculation` | Your arithmetic on published inputs. A reader can reproduce it. |
| `assumption` | An internal estimate. No source supports it. |
| `sensitivity` | A value chosen to test a range. It is not a finding. |
| `unratified` | Sources conflict. **This class never reaches a slide.** |

Three rules follow, and they are not negotiable:

1. **Never publish a self-derived quotient.** Give the source values. Let the reader divide. A quotient hides which input is weak.
2. **An `unratified` figure stays off the deck.** Close the conflict, or omit the number. Do not average conflicting sources.
3. **Never collapse a mixed subtotal into one headline number.** A total built from a vendor price plus a large assumption is useful only while every input stays visible. State the band, not the point.

Showing the class system on its own slide is a strength. It tells an investor which numbers are load-bearing and which wait on a quote.

## Workflow

1. Read the source material. Find the numbers, the milestones, and the current state.
2. Name the audience, the purpose, the duration, and the ask. Ask the user when the purpose is unclear. A duration of 5, 10, or 20 minutes changes the slide count.
3. State the thesis in one sentence. The thesis is the change the deck must cause, not the topic.
4. Class every figure. Record the source for each one. Delete each `unratified` figure now, before it reaches a draft.
5. Select the structure from `references/deck-structures.md`. Change the order only when the argument requires it.
6. Draft a slide table: audience question, claim, evidence, visual.
7. Write each headline as a claim. See "Headlines" below.
8. Date every status claim in the text of the slide.
9. Invoke `slidev-presentation` to build, render, inspect, and export the deck.
10. Run `references/honesty-checklist.md`.

## Headlines

A headline states a claim. A label states a topic. Write claims.

| Do not write | Write |
| --- | --- |
| Market size | A $47B market, growing 23% a year |
| Our team | Two founders, split along the actual seam |
| Traction | 40 paying customers in 6 months, none churned |
| Roadmap | From one prototype to one paying pilot |

A reader who reads only the headlines MUST be able to follow the whole argument.

## Dated claims

A status claim decays. A reader cannot tell a current claim from a stale one.

- Write the date in the slide text: "as of 2026-08-05", not "currently".
- Give a live system its own slide with two columns: what runs now, and what is not yet true.
- Re-date every status line before you present the deck again.

The "not yet true" column looks like a weakness and reads as credibility. A reader who finds one overstatement stops trusting every other slide.

## What the deck must state plainly

State these where they apply. Do not bury them in an appendix.

- No signed contract, no delivery date, and no recognized revenue, when each is true.
- What a result does **not** prove. One test in one configuration does not make a general requirement.
- Which comparison is an external benchmark, and how it differs from your work.
- Which price is cost-plus arithmetic and which price a buyer has agreed to pay.

## Validation

- The deck MUST NOT contain a figure without an evidence class.
- The deck MUST NOT contain an `unratified` figure.
- Every status claim MUST carry a date.
- Every headline MUST state a claim.
- The final slide MUST state the ask.
- The deck SHOULD name the one number you cannot generate internally. That number is usually the best ask.

## Diagnostics

| symptom | likely cause | fix |
| --- | --- | --- |
| A number appears in two documents with two values | No document owns the figure | Give the figure one home. Link to that row from everywhere else. |
| A headline reads as a section label | The slide has a topic, not a claim | Write the takeaway sentence. If you cannot, the slide has no claim — cut it. |
| The deck feels defensive | Limits are stated without the result beside them | Put each limit next to the claim it bounds, not on a separate caveat slide. |
| An investor asks "where did that come from?" | A quotient hid its inputs | Show the source values. Remove the derived rate. |
| A status slide is wrong a week later | The claim had no date | Date the line. Re-date it before each presentation. |
| The ask slide lists five requests | The asks are not ranked | Give three, ranked by how much each changes the trajectory. |

## Attribution

The investor and sales slide orders come from the community `pitch-deck-creator` skill, at
<https://github.com/lionelsimai/claude-skills-collection/blob/main/skills/pitch-deck-creator/SKILL.md>,
read on 2026-08-07. The evidence-class system, the dated-claim rule, and the honesty checklist are local additions.
