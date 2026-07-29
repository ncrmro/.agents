---
generated: true
updated: <YYYY-MM-DD>
mission: "<one sentence — what this project is for>"
repos:
  - <owner>/<repo>
tags: [<2–5 tags from wiki/tags.md>]
---

# <slug>

<Two to four sentences: what the project is, where its canonical checkouts
live, and the remote form. Link out with [[wiki links]] rather than restating
concepts the vault already holds.>

Session history: [[projects/<slug>/SESSIONS|sessions]].

Repos:

- **<repo>** — <what it owns>.

## M<n> — <milestone name>

**Status:** <active | blocked | shipped> in
[PR #<n>](<url>) at `<sha>`. The canonical milestone package is
`<path in repo>`.

<A short paragraph on what the milestone proves or delivers, and what is
explicitly out of scope.>

<Optional projected git graph — see the project-planning skill. Time flows
upward; `◉` in flight, `○` planned, `●` on main.>

## Open Tasks

Refreshed <YYYY-MM-DD> from `scripts/gather.sh <slug>`.

<!-- Row forms — the checkboxes are commented out so an unfilled template does
     not register placeholder tasks. Uncomment as real rows replace them. The
     status box mirrors forge state: [ ] no PR yet, [/] PR open, [x] merged,
     [-] closed unmerged.

- [ ] <task> — [Issue #<n>](<url>) #<project-tag> #task 🔼 📅 <YYYY-MM-DD>
- [/] <task with a PR in review> — [Issue #<n>](<url>) · [PR #<n>](<url>) #<project-tag> #task
- [/] <base of a stack> — [PR #<n>](<url>) #<project-tag> #task 🆔 <id>
- [ ] <stacked on it> — [PR #<n>](<url>) #<project-tag> #task ⛔ <id>
- [ ] <work with no forge item> — `<branch>` in <owner/repo> #<project-tag> #task
-->

### M<n> — <milestone name>

### Unscheduled

### Platform

<Not user- or customer-facing: CI, runners, deploy, build and toolchain,
dependencies, observability, repo and agent tooling, invisible refactors.
`project-planning` defines the boundary.>

<!-- Keep the `preset project_open` line. The vault's global query is prepended
     to every block; the preset opts out of it, so this query keeps working
     whatever that setting is. It renders rows tagged for this project from
     elsewhere in the vault — dailies, research notes — never the rows above.
     Preset defined in .obsidian/plugins/obsidian-tasks-plugin/data.json as:
     ignore global query / not done / group by heading / sort by due -->

```tasks
preset project_open
(tags include #<project-tag>) AND NOT (path includes wiki/projects/<slug>)
```

## Recently closed

- [PR #<n>](<url>): <title> · merged <YYYY-MM-DD>
- [Issue #<n>](<url>): <title> · closed <YYYY-MM-DD>
