---
updated: YYYY-MM-DD
landing: fast-forward   # fast-forward | merge-commit — never squash a planned span
stage_default: manage   # explore | ship | manage | program
---

# <project> plan

<One paragraph: the goal of the next release, and why this order.>

```text
◇  vX.Y.Z (next)
│
○  feat(<scope>): <second planned commit>
○  feat(<scope>): <first planned commit>
│ ◉  feat(<scope>): <in-flight commit>     PR #_  <head> → main · in review
├─╯
●  <most recent shipped commit>            <sha>   ← main
◇  vX.Y.Z — YYYY-MM-DD
```

## Landing agreement

Every `○` above lands on main as its own commit, by the mode in this file's
`landing:` field — never squashed.

If one `●` appears where the plan drew several, the span was squashed: unpack it
per the `project-planning` skill's recovery procedure rather than redrawing this
graph to match what landed.

## Governance

- **Workstream overrides:** <name, stage, and reason; or none>
- **Current/core:** <issues that gate the active milestone demo>
- **Current/stretch:** <non-gating issues assigned to the active milestone>
- **Next:** <the next milestone's intended outcome; keep its tasks coarse until
  it becomes current>
- **Later:** <link to the unscheduled candidate backlog>
- **Review trigger:** a release, experiment or user-test result, blocker,
  incident, or change to scope, priority, dependency, or capacity
- **Review cadence:** at least weekly at Manage or Program

## Notes

<Decisions, risks, links. Prose lives here — the graph stays data.>
