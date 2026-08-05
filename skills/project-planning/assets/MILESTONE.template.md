# M<n> — <Milestone name>

> **<Headline a customer would read.>** <The paragraph you would publish the
> day this ships: what someone can now do that they could not before, in their
> language, not the implementation's. If this paragraph cannot be written
> without lying, the milestone is not scoped yet — cut it until it can.>

| | |
| --- | --- |
| **ID** | M<n> (`N` while draft/RFC; a number once tracked) |
| **Status** | Draft \| Active \| Shipped |
| **Stage** | `<stage>` (Explore, Ship, Manage, or Program); record the reason when it overrides the project default |
| **Flag or gate** | `<feature_flag_name>` — off by default on main \| `<containment, reversibility, or verification gate>` |
| **Persona** | [<Role — Org>](../../personas/<slug>.md) |
| **Report** | [<YYYY-MM-QN plan>](../../reports/<file>.md) |

## The quote

> "<The sentence the persona could honestly say after using this.>"
> — <Role>, <Org>

If you cannot source this quote from a real reaction after the demo, mark it
`ASPIRATIONAL` and treat that as a scope warning, not a copywriting problem.

## Scope and commitment

**Primary outcome or uncertainty:** <the one result this milestone exists to
produce>

For an experimental milestone:

- **Independent variable axis:** <the one thing that changes>
- **Fixed controls:** <apparatus, protocol, environment, measurements, and
  analysis that do not change>

### Core — gates milestone closure

Requirements this milestone satisfies (it does not invent obligations — it
selects them):

- `<PREFIX>-NNN.M` — <one line on what closing it means here>
- `<PREFIX>-NNN.M` — <…>

### Stretch — assigned, non-gating

- <work on the same outcome or variable axis that can use spare
  capacity without delaying core>

Assign current stretch issues to the forge milestone and mark them as stretch.
They do not gate closure. When the core demo passes, close the milestone and
move unfinished stretch to `next` or `later`.

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
