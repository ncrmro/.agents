# M<n> — <Milestone name>

> **<Headline a customer would read.>** <The paragraph you would publish the
> day this ships: what someone can now do that they could not before, in their
> language, not the implementation's. If this paragraph cannot be written
> without lying, the milestone is not scoped yet — cut it until it can.>

| | |
| --- | --- |
| **ID** | M<n> (`N` while draft/RFC; a number once tracked) |
| **Status** | Draft \| Active \| Shipped |
| **Flag** | `<feature_flag_name>` — off by default on main |
| **Persona** | [<Role — Org>](../../personas/<slug>.md) |
| **Report** | [<YYYY-MM-QN plan>](../../reports/<file>.md) |

## The quote

> "<The sentence the persona could honestly say after using this.>"
> — <Role>, <Org>

If you cannot source this quote from a real reaction after the demo, mark it
`ASPIRATIONAL` and treat that as a scope warning, not a copywriting problem.

## What it scopes

Requirements this milestone satisfies (it does not invent obligations — it
selects them):

- `<PREFIX>-NNN.M` — <one line on what closing it means here>
- `<PREFIX>-NNN.M` — <…>

Explicitly **out** of scope, and why:

- <thing a reader would reasonably assume is included>

## The demo

- **Channel(s):** <where this goes out — investor update, standup recording,
  changelog post, customer call. A milestone with no channel is one nobody
  sees.>
- **Audience:** <the persona above, or who stands in for them>
- **Script:** <the numbered walkthrough — what is clicked, what is shown, what
  the honest failure looks like if it fails. Write this before implementing;
  it is the fastest scope check available.>

## Success criterion

<One sentence, falsifiable. "X is computed rather than authored, and a test
asserts the rendered value" — not "X works well".>

## Honesty boundary

<What this milestone must not be read as claiming. Modelled ≠ flown, scenario
data ≠ contracted demand, a passing budget gate ≠ an approved trajectory.>

## References

- Personas, requirements, and the report this serves (linked above)
- Prior/adjacent milestones: <…>
