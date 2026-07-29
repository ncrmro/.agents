---
name: project-notes
description: Track a project's PRs, issues, and milestones in the personal notes vault at ~/notes/wiki/projects/<slug>/, keep the surrounding wiki pages in sync, record each agent session in the project SESSIONS log, and enrich the vault from notes that live in the project's own repos. Use when asked what's happening on a project, to refresh or create a project page, to record a PR/issue/milestone, to log or resume an agent work session, or to pull an in-repo wiki or runbook into personal notes.
---

# Project notes

One directory per project in the personal vault, `~/notes/wiki/projects/<slug>/`,
is the durable record of what a project is, what is in flight on its forge, and
how to resume work on it:

```text
~/notes/wiki/projects/<slug>/
├── README.md      # current state — mission, repos, milestones, Open Tasks
└── SESSIONS.md    # agent session history — who did what, and how to resume it
```

The vault is an Obsidian-style knowledge base that auto-commits and pushes every
few minutes (obsidian-git). **Do not manage commits in `~/notes` by hand** and
do not rely on specific hashes persisting. Read `~/notes/AGENTS.md` first: it
records the vault's live conventions and overrides anything here that has drifted.

## Boundaries

| Concern | Owner |
| --- | --- |
| Project page, forge tracking, session log, vault sync, in-repo → vault harvest | this skill |
| The projected git graph (`◉ ○ ● ◇` rows, stacked PRs), and what counts as platform work | `project-planning` |
| Note anatomy, frontmatter, tags, sources, `index.md` / `log.md` rules | `wiki` |
| Creating or mutating forge issues, PRs, milestones | `git-forge` |
| The repo-level `TASKS.md` / `PLAN.md` / `CHANGELOG.md` handoff triad | `project-context-handoff` |

This skill reads the forge and writes the vault. It never opens, closes, or
edits forge items. Hand that to `git-forge`, and only on explicit request.

This skill owns resumable work state in the vault. It replaces the former
`work-continuity` skill and its `chapters` tool, which kept work arcs in a
machine-owned region of the project page: a multi-session arc is now a milestone
section plus its `### M<n>` task grouping, and per-session resume state is a
`SESSIONS.md` entry. Nothing here is machine-owned, so edit it directly.

`SESSIONS.md` is vault-level and newest first. It is not `project-planning`'s
`CHANGELOG.md`, which is repo- or org-level and append-only, nor
`project-context-handoff`'s triad, which lives in a repo. Different files at
different altitudes; never merge them.

## README.md anatomy

`assets/README.template.md` is the starting point. Sections, in order:

- **Frontmatter** — the machine-readable header: `generated: true`, `updated`
  (today, whenever the page changes), `mission`, `repos` (an `owner/repo` list;
  the scripts parse this), and 2–5 `tags` that already exist in
  `~/notes/wiki/tags.md`. A new tag is added to `tags.md` in the same run.
- **Description** — a few sentences plus a repo-by-repo list. Link out with
  `[[wiki links]]`; do not restate concepts the vault already holds.
- **Milestone sections** — one `## M<n> — <name>` per active milestone: status,
  the PR or package that is canonical, what it proves, what is out of scope,
  and optionally a projected git graph from `project-planning`.
- **Open Tasks** — the single view of everything in flight, every row carrying
  its forge references. See [Open Tasks](#open-tasks) below.
- **Recently closed** — issues and PRs closed since the last refresh, with the
  date `scripts/gather.sh` was last run.
A multi-session work arc is a milestone section plus its task grouping; it needs
no section of its own.

## SESSIONS.md anatomy

`assets/SESSIONS.template.md`. **Newest entry first**, directly under the
heading — the opposite of `wiki/log.md`, which appends at the bottom.

One entry per agent session that changed something. Six fields, all required:

```markdown
## [2026-07-29] Fleet host bootstrap milestone docs

- agent: claude-code · opus-5 · session `a1b2c3d4-…` · resume `claude --resume a1b2c3d4-…`
- branch: `docs/milestone-m1` in example-org/os · worktree `~/repos/example-org/os.worktrees/docs/milestone-m1`
- head: `b8ccbf5 docs(milestones): define fleet host bootstrap`
- work: drafted the M1 package; VM proof only, no physical-host claim
- refs: [PR #5](https://forge.example.com/example-org/os/pulls/5)
- next: enrol the second YubiKey and reboot-test slot 2
```

- `agent:` — harness and model (`claude-code · opus-5`, `codex`, a delegated
  subagent), plus the session id and the command that resumes it. State the
  model yourself; it is not in the environment.
- `branch:` — branch, repo, and worktree path. The worktree path is what gets a
  later reader back to the files.
- `head:` — the tip commit at the end of the session, so a later reader can tell
  what has since been rebased or squashed away.
- `work:` — what changed and what it proves. Carry the evidence class: a VM
  proof is not a physical-host claim, a read-only audit is not a change. Name
  what the result did not establish.
- `refs:` — issues and PRs, in the vault link form.
- `next:` — the first thing to do on resume. An entry without it is just a
  commit log.

`scripts/session-entry.sh` prints this skeleton prefilled; fill the rest before
pasting it in.

Entries are immutable once written. Correct a wrong entry with a later one that
says what was wrong; never rewrite history that a resume handle points at.

## Open Tasks

Every project page carries one `## Open Tasks` section; it is the only place open
work is listed. Gathered open issues and PRs land here as rows.

Rows are [Obsidian Tasks](https://github.com/obsidian-tasks-group/obsidian-tasks)
items. Read [`references/obsidian-tasks.md`](references/obsidian-tasks.md) before
writing or querying them; it covers the line format, dependencies, and the vault
settings that silently blank a query.

### Tags

Two vocabularies, easy to conflate. Frontmatter `tags:` are the controlled
vocabulary in `~/notes/wiki/tags.md`, which deliberately holds *no* project tags;
pages link through shared domain tags. Inline tags on task rows are routing, not
vocabulary: `#<project>` scopes the row and `#task` marks it. The project tag is
the slug made tag-safe, since `.` is not: `example.org` → `#example-org`. Match
whatever the project's existing rows already use.

### References

Every row names an issue and one or more pull requests or branches:

```markdown
- [/] Derive encrypted roots from host kind — [Issue #2](url) · [PR #5](url) #example-org #task 🔼 📅 2026-08-15
```

The status box mirrors forge state where the vault defines the custom statuses
for it (`assets/README.template.md` records the mapping): `[ ]` no PR yet, `[/]`
PR open, `[x]` merged, `[-]` closed unmerged. `[/]` is `IN_PROGRESS`, the `◉` of
a `project-planning` graph, so `status.type is IN_PROGRESS` answers "what is in
review" across the whole vault.

- An issue with no PR yet: name the issue alone; add the branch once it exists.
- A PR with no issue: the PR is the reference. Normal for small work.
- Neither, as when vibecoding: reference the branch, or the repo when the work
  is on `main`. A row with no reference at all is allowed only when the work has
  no forge trace yet; say where it lives.

### Grouping

When the project has milestones, group rows under an `### M<n> — <name>`
subsection matching the milestone sections above, in milestone order. Work
belonging to no milestone goes under `### Unscheduled`. With no milestones
anywhere, a flat list under `## Open Tasks` is correct; do not invent them.

Platform work gets its own `### Platform` subsection, outside the milestone
grouping. `project-planning` defines what counts as platform work; the template
enumerates the usual categories.

Stacked PRs become `🆔`/`⛔` dependencies, so `is not blocked` surfaces exactly
the lowest `○` of the `project-planning` graph.

### Human-authored rows

Keep rows and references current, but never delete a human's task. Checking one
off with `[x]` and a date is allowed only when it is verifiably done: a merged
PR is evidence, an open one is not.

## Workflow

### 1. Resolve the project

Map the request to a slug: an existing directory under
`~/notes/wiki/projects/`, or the org that owns the repo in question.
`~/notes/wiki/projects.md` is the index of active projects, and
`~/notes/AGENTS.md` maps each org to its repos and local paths. Projects can
span orgs: the `repos:` list, not the slug, decides what gets gathered.

If the project has no directory, confirm it is worth tracking before creating
one, then copy both templates into `<slug>/` and add a row to the **Active**
table in `projects.md`.

Older projects are still a flat `~/notes/wiki/projects/<slug>.md`, and the
scripts read either. When you touch one, migrate it in the same run: `mv
<slug>.md <slug>/README.md`, add `SESSIONS.md`, and repoint the inbound links
(step 5).

### 2. Gather forge state

```sh
~/.agents/skills/project-notes/scripts/gather.sh <slug> --since <last refresh>
```

It reads `repos:` from the page frontmatter, picks the forge from each clone's
`origin` remote, and prints open PRs, open issues, milestones, and items closed
since the given date. `--help` covers the other forms; run `--since` alone,
since its output is a superset of the bare form's.

For release state, shipped commits, and milestone directories, run
`project-planning`'s `scripts/state.sh` instead; it accepts several repos in one
call.

Anything not in the gathered output or read directly from the forge does not go
on the page.

### 3. Update README.md

- Refresh `Open Tasks` wholesale from the gathered output and stamp the refresh
  date, keeping the milestone / Unscheduled / Platform grouping. Gathered rows
  arrive as plain links; add the checkbox, description, and tags. Move closed
  items to `Recently closed`, and drop rows closed more than 30 days before the
  refresh date — the forge is the archive, the page is the view.
- Promote milestone status when a PR opens, lands, or a milestone closes. Update
  the graph by promotion (`○ → ◉ → ●`), never by rewriting shipped rows.
- Bump `updated:` and keep `generated: true`.

### 4. Record the session in SESSIONS.md

Whenever the session changed something (code on a branch, a PR opened, a
milestone promoted, this page rewritten), prepend an entry:

```sh
~/.agents/skills/project-notes/scripts/session-entry.sh --agent 'claude-code · opus-5'
```

Run it from the repo worktree so it picks up branch, repo, worktree, and head;
fill `work:`, `refs:`, and `next:` yourself, then prepend the entry above the
previous one. A session that only read things does not earn an entry.

When resuming, read the top of `SESSIONS.md` first: its `next:` is the task and
its `branch:` is where the files are.

### 5. Propagate

Update all of the following in the same run:

- `~/notes/wiki/projects.md` — the Active/Archived tables and missions.
- `~/notes/wiki/index.md` — an entry for every new page.
- `~/notes/wiki/log.md` — one entry, in the form the `wiki` skill documents.
- `~/notes/wiki/tags.md` — any frontmatter tag used for the first time. Inline
  task tags are not part of that vocabulary; see [Open Tasks](#open-tasks).

Inbound links are path-qualified: `[[projects/<slug>/README|<slug>]]`. Every
project's page is named `README.md`, so a bare `[[README]]` is ambiguous
vault-wide and Obsidian will resolve it to the wrong project. When migrating a
flat page, rewrite its inbound `[[projects/<slug>|…]]` links along with it.

Superseding a project: mark the old `README.md` as superseded with a link
forward, move its row to **Archived** in `projects.md`, and leave both the
history and the changelog in place.

### 6. Enrich from the project's own wiki

Repos carry their own knowledge: an org wiki repo (`<org>/wiki` with a `wiki/`
tree), `docs/concepts/`, `docs/runbooks/`, `docs/adr/`. Find what the vault is
missing:

```sh
~/.agents/skills/project-notes/scripts/harvest.sh <slug>
```

`NEW:` rows have no counterpart in `~/notes/wiki/`; `have:` rows do and should
be checked for drift. Then decide per file:

- **Durable domain knowledge** (how a system works, why a decision was made) →
  a vault note under `wiki/concepts/` or `wiki/research/`, written per the
  `wiki` skill. Summarize and link back to the repo path; do not copy a long
  document wholesale, and do not fork a doc that is better maintained in the
  repo — link it from the project page instead.
- **Operational detail** tied to one repo (build steps, local runbooks) → leave
  it in the repo.
- **Already in the vault** → update the vault note and record the divergence,
  rather than creating a second copy.

Flow is one-way: repo → vault. Do not edit an external repo from this skill
unless the task explicitly authorizes it.

## Conventions

- Links: the number lives inside the link text — `[Issue #123](url)`. Join
  several with ` · `; the gathered and `Recently closed` forms append `: Title`.
- Dates are absolute (`2026-07-29`), never "last week".
- Never invent an issue number, a URL, a status, or a resume handle. When one is
  unavailable, say so.
- Checkout and worktree paths come from `~/notes/AGENTS.md` and the repo-root
  `CLAUDE.md`; read them rather than assuming, since they differ by org and the
  SESSIONS log records the worktree path as a resume handle.
- On a project where you are one contributor among many — an employer org, a
  large open-source org — scope forge queries to your own involvement
  (`involves:@me`, `--author <you>`) and never report org-wide activity unless
  asked. The consumer's `AGENTS.md` names which projects these are.
