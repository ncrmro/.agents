# ASCII graph templates

Templates for every planning scenario, plus the drawing rules that keep graphs
consistent. Time always flows up: bottom = shipped, top = future, next release
on top.

Two view modes:

- **Release column** (section A) — everything drawn flat, where it lands on
  main; topology deliberately omitted. The everyday view for plans and
  reports.
- **Branch view** (sections B–E) — branches drawn as parallel vertical lanes
  beside main. Use whenever PR or milestone topology matters.

The modes mix within one graph, and usually should: lanes where branches
exist, flat above where they do not.

## Drawing rules

- Glyphs: `◇ ● ◉ ○`. Box-drawing characters: `│ ├ ─ ╮ ╯`.
- main is the leftmost column and holds only commits that are on main, so `●`
  never appears in a lane. Each branch is a vertical lane to the right: lane
  *n*'s glyph column is indented 2·*n* characters (`│ ◉`, `│ │ ○`). A stacked
  PR forks from its parent PR's lane and sits one lane further right. Messages
  follow their glyph after two spaces, so message columns differ by lane
  depth; only the annotation column is aligned.
- A lane forks at a `├─╯` row and, once merged, closes at a `├─╮` row; the
  `├` sits on the parent column. A fork row attaches to the first commit
  below it in the parent column — that commit is the base. An open PR has
  only the fork; reading upward, its lane just ends.
- Each lane is a contiguous block of rows; its column does not exist above its
  top commit, which is what lets a later lane reuse it.
- Milestone boundaries ride the milestone branch's merge row:
  `├─╮  ── milestone: <name> ──`. Where the boundary has no merge row to ride,
  use a bare `│  ── milestone: <name> ──` separator on main's column instead.
- Flagged milestones note their flag on the boundary row
  (`── milestone: <name> · flag: <flag> ──`) and draw the default-on flip as
  its own commit on main above the merge. Semantics: SKILL.md § Feature
  flags.
- Annotations (shas, PR labels, status) start at one consistent column per
  graph, two spaces past the graph's longest message row. Annotate a lane
  once, on its top commit: `PR #n  <head> → <base> · <status>`, or the short
  `PR #n · <status>` where topology is omitted or a lane→branch key (a
  worktree map, a PR list) sits beside the graph. Shipped rows carry the short
  sha instead. Optionally mark main's tip: append `← main` to the newest `●`
  row. Keep messages ≤ 50 chars (normal git subject discipline) so a graph
  fits in ~100 columns. Lane depth shifts messages right; past about four
  lanes the aligned annotation column no longer fits, so split the graph or
  fall back to the release column.
- Bare `│` rows only to set off regions: below the top `◇`, and between
  groups. No `│` row between consecutive commits in the same group, and none
  above the bottom `◇` — the shipped commits run straight into it.
- Release rows: `◇  vX.Y.Z (next)` for the predicted release,
  `◇  vX.Y.Z — YYYY-MM-DD` once shipped. Never list the
  `chore(main): release …` commit; `◇` stands for it.

## A. Release column (the everyday minimal form)

Everything drawn as it lands on main; no branch topology.

```text
◇  v1.4.0 (next)
│
○  feat(search): fuzzy matching
○  fix(search): index rebuild on schema change
◉  feat(search): index postings table           PR #12 · in review
│
●  feat(core): extract search module            4f2a91c
●  chore: bump deps                             d81b3aa
◇  v1.3.0 — 2026-07-02
```

Read: two commits shipped since v1.3.0, one commit in review, two more
planned, and landing them all predicts v1.4.0 (the `feat`s force a minor
bump).

## B. Stacked PRs

Each deeper PR in the stack is one lane further right. A fork row lines up
with the commit it branches from: PR #2 forks from main's `feat(db): user
table`, PR #3 forks from PR #2's `token endpoint`.

```text
◇  v0.3.0 (next)
│
│ │ ○  feat(auth): session refresh  PR #3  feat/auth-ui → feat/api-tokens
│ │ ○  feat(auth): login form
│ ├─╯
│ ◉  feat(api): token endpoint      PR #2  feat/api-tokens → main · in review
├─╯
●  feat(db): user table             a1b2c3d
●  chore: scaffold                  9f8e7d6
◇  v0.2.0 — 2026-07-10
```

Stacks merge bottom-up: #2 lands first, #3 is retargeted to main and lands
after. As that happens, lanes collapse leftward: a landed lane's commits
promote to `●` and join the main column.

## C. Parallel PRs

Independent PRs, all based on main — separate lanes whose fork rows stack
above the shared base commit. Vertical order between open lanes carries no
meaning: parallel work is unordered.

Single-commit lanes compress into lane 1, since a column is free above the
lane below it:

```text
│ ○  feat(export): csv download  PR #5  feat/export → main
├─╯
│ ◉  fix(auth): logout redirect  PR #4  fix/logout → main · in review
├─╯
●  feat(db): user table          a1b2c3d
```

When one lands, its lane collapses into the main column and the other
rebases on top.

Give each lane its own column when the lanes are multi-commit, or when the
graph maps lanes to concurrent workers and the simultaneity is the point.
Stack the fork rows on the shared base, widening by two each time, and order
the lanes deepest-lowest so every column ends at its own top commit:

```text
○  feat(web): read trips from the API
│ ◉  feat(web): booking flow states              PR #44 · in review
│ ◉  feat(web): itinerary view against fixtures
│ │ ◉  feat(api): filter and pagination params   PR #46 · in review
│ │ ◉  feat(api): serve the fixture contract
│ │ │ ◉  ci(deploy): preview environment per PR  PR #47 · in review
│ │ │ ◉  ci(deploy): stack skeleton
├─╯ │ │
├───╯ │
├─────╯
●  feat(fixtures): trip contract and seed data   a1b2c3d  ← main
```

Reading upward, the three fork rows open lane 3, then lane 2, then lane 1,
all from the same base — the notation for three worktrees cut at the same
sha. Each lane is typically one worktree, the branch name doubling as the
path (SKILL.md § Project Repos).

## D. Milestones within a release

Each milestone's work is a branch lane parallel to main; the milestone
boundary is its merge row. The lower lane executes first.

```text
◇  v0.4.0 (next)
│
○  feat(billing): enable billing_v2 flag
├─╮  ── milestone: billing foundation · flag: billing_v2 ──
│ ○  feat(billing): stripe webhooks       PR #8  feat/billing → main
│ ○  feat(billing): plan model
├─╯
├─╮  ── milestone: self-serve onboarding ──
│ ○  feat(onboarding): signup wizard      PR #7  feat/onboarding → main
│ ○  feat(onboarding): invite flow
├─╯
│ ◉  feat(auth): session refresh          PR #6  feat/session → main · in review
├─╯
●  feat(auth): login form                 88c1f02
◇  v0.3.0 — 2026-07-18
```

## E. Multi-release roadmap

Stack releases only when laying out beyond the next one. Farther up = less
certain; keep distant sections coarse and flat.

```text
◇  v0.5.0 (later)
│
○  feat(billing): dunning emails
○  feat(billing): usage-based invoices
│
◇  v0.4.0 (next)
│
○  feat(onboarding): signup wizard
│ ◉  feat(api): token endpoint          PR #2  feat/api-tokens → main · in review
├─╯
●  feat(db): user table                 a1b2c3d  ← main
◇  v0.3.0 — 2026-07-10
```
