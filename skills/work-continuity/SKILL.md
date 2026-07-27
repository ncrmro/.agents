---
name: work-continuity
description: Maintain durable, resumable coding work arcs across harnesses. Use when creating or reviewing work arcs, recording tasks, linking issues/PRs, preserving session resume state, or falling back to scripts when the native chapters tool is unavailable.
---

# Work Continuity

A **work arc** is a bounded unit of coding work with scope, tasks, external refs,
validation, and enough resume state for another agent or future session to continue.
In this environment, project arcs are usually recorded as **chapters** in
`<vault>/wiki/projects/<project>.md`.

## Tool preference

1. If a native `chapters` tool exists, use it.
2. Otherwise run this skill's script fallback:

```bash
python "$SKILL_DIR/scripts/chapters" '{"entity":"chapter","action":"status","args":{"project":"ai-outfitter"}}'
```

3. If neither exists, edit manually only as a degraded path and only after reading the
project's chapter-format rules. Never hand-edit a machine-owned region when a tool or
script can do the write.

When invoking scripts from this skill, resolve paths relative to this skill directory.
If your harness does not expose `SKILL_DIR`, use the absolute path to this skill.

## Intake before creation

Opening a new named work arc is an intake operation, not a blind write. Before creating
an arc, discover context unless the user explicitly asks for an empty placeholder:

```bash
python "$SKILL_DIR/scripts/chapters" '{"entity":"chapter","action":"discover","args":{"project":"ai-outfitter","chapter":"personas"}}'
```

`chapter.open` defaults to no-write intake mode. To intentionally create an empty arc:

```bash
python "$SKILL_DIR/scripts/chapters" '{"entity":"chapter","action":"open","args":{"project":"ai-outfitter","chapter":"personas","mode":"placeholder"}}'
```

To create after intake with known scope:

```bash
python "$SKILL_DIR/scripts/chapters" '{"entity":"chapter","action":"open","args":{"project":"ai-outfitter","chapter":"personas","repos":["ai-outfitter/wiki"],"confirm":true}}'
```

## Harness-agnostic rules

- Reads MAY be fuzzy and broad; writes MUST resolve to exactly one target or fail with
  candidates.
- Record tasks under the active arc they belong to. Put loose one-offs in the project's
  human-owned task surface.
- Preserve external refs as links to their canonical system of record.
- Record session resume state when available: harness, cwd, last-active date, and resume
  command.
- Treat generated, lock-managed, or tool-owned regions as opaque. Use the owning tool or
  script.
- Keep one projected work graph per repo. Tie repos with milestones; do not collapse
  multi-repo work into a fake single timeline.

## Script surface

The fallback script mirrors the native single-tool shape:

```json
{"entity":"chapter","action":"status","args":{"project":"keystone","include":["tasks","links","sessions"]}}
```

Supported actions:

- `project.status`
- `project.discover`
- `chapter.status`
- `chapter.discover`
- `chapter.open`
- `chapter.close`
- `task.add`
- `task.check`
- `link.add`
- `session.attach`

Environment:

- `CHAPTERS_NOTES_DIR` defaults to `~/notes`.
- `CHAPTERS_REPOS_ROOT` defaults to `~/repos`.
- `CHAPTERS_OUTPUT=json` prints a JSON envelope; default is text.
