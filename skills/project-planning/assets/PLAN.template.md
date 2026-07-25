---
updated: YYYY-MM-DD
landing: fast-forward   # fast-forward | merge-commit — never squash a planned span
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

## Notes

<Decisions, risks, links. Prose lives here — the graph stays data.>
