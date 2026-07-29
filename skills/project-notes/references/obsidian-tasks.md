# Obsidian Tasks — the subset project pages use

[obsidian-tasks-group/obsidian-tasks](https://github.com/obsidian-tasks-group/obsidian-tasks).
Docs: <https://publish.obsidian.md/tasks/>. This file records the parts that
matter for project pages; read the docs for anything beyond it.

## The line format

A task is a markdown checklist item. Everything before the first emoji field is
the **description**; the emoji fields follow it, at the end of the line.

```markdown
- [ ] Derive encrypted roots from host kind — [Issue #2](url) · [PR #5](url) #example-org #task 🔼 📅 2026-08-15
```

Markdown links, inline code, and tags are all fine inside the description, so
the forge references live there.

### Field signifiers

| Emoji | Field | Value |
| --- | --- | --- |
| ➕ | created | `YYYY-MM-DD` |
| 🛫 | start | `YYYY-MM-DD` |
| ⏳ | scheduled | `YYYY-MM-DD` |
| 📅 | due | `YYYY-MM-DD` |
| ✅ | done | `YYYY-MM-DD` |
| ❌ | cancelled | `YYYY-MM-DD` |
| 🔺 ⏫ 🔼 🔽 ⏬ | priority | highest / high / medium / low / lowest |
| 🔁 | recurrence | e.g. `every week` |
| 🆔 | id | letters, digits, `_`, `-` |
| ⛔ | depends on | comma-separated ids |
| 🏁 | on completion | `keep` / `delete` |

Dates only work as query filters in these fields. A date written into the
description text is invisible to every `due`/`scheduled` filter.

Default (no priority signifier) is *normal*, which sits between 🔼 medium and
🔽 low — omitting the emoji is not the same as low priority.

## Vault settings — read them, don't assume

The global filter and global query are vault configuration, not convention, and
they are the usual reason a correct-looking query returns nothing. **Read
`<vault>/.obsidian/plugins/obsidian-tasks-plugin/data.json` rather than assuming
either value** — this file documents the mechanism, not one vault's settings.

- **`globalFilter`**, when set to a tag such as `#task`, means a checklist item
  without that tag is not a task at all and appears in no query. When empty,
  *every* checklist item in the vault is a task — including placeholder rows in
  an unfilled template, which is why the template comments its example rows out.
  Either way, tagging project rows `#task` is worth doing: it keeps them
  greppable and survives the filter being turned on later. A tag used as the
  global filter cannot take sub-tags, so `#task/platform` would break it.
- **`globalQuery` is prepended to every query block.** A non-empty one silently
  narrows every query in the vault, including pages far from whatever it was
  meant to scope. Opt out per block with `ignore global query` (Tasks 4.6.0+),
  which is why project-page queries carry that line whether or not the setting
  is currently empty:

  ```tasks
  ignore global query
  not done
  (tags include #example-org) AND NOT (path includes wiki/projects/example-org)
  ```

A vault can also define **presets** — named instruction snippets in `data.json`,
used as `preset <name>` inside a block. A project vault typically defines one
holding the boilerplate above, so pages carry only their own filter line.

## Dependencies — stacked PRs

`🆔` names a task; `⛔` lists the ids it waits on. This maps directly onto a
stacked PR: the base carries the id, the stacked one depends on it.

```markdown
- [ ] Add ISO and offline bootstrap — [PR #6](url) #example-org #task 🆔 os-iso
- [ ] Stabilize the bare-metal path — [PR #7](url) #example-org #task ⛔ os-iso
```

`is not blocked` then surfaces only what is actionable.

Limits worth knowing: ids should be unique vault-wide (nothing enforces it, and
a duplicated id makes a dependent wait on *every* copy); adding four or more
dependencies at once is error-prone; recurrence drops dependency fields; and
urgency scoring ignores dependencies entirely.

## Queries

A query is a `tasks` code block. Instructions are one per line and, apart from
boolean operators, regexes, and custom JS, case-insensitive.

Filters used on project pages:

```text
not done
done
due before tomorrow
happens this week
no due date
tags include #example-org
path includes wiki/projects
heading includes Platform
is not blocked
priority is above low
```

Booleans need **uppercase** operators and parenthesized sub-expressions:

```text
(tags include #example-org) AND NOT (path includes wiki/projects/example-org)
```

Shaping the output:

```text
group by heading        # h4 headings; second group by → h5, third → h6
group by priority
sort by due
limit 20
short mode
hide backlink
```

`group by heading` groups by the nearest preceding heading, which is why the
Open Tasks subsections are real headings — a vault-wide query can regroup rows
by milestone or Platform without any extra metadata. Group headings sort
case-sensitively alphabetically, not in source order: `M1`, `M2`, `M3` come out
right, and `Platform` / `Unscheduled` sort after them.

Query results are views of lines that live in files: editing a task through a
query edits its source line.
