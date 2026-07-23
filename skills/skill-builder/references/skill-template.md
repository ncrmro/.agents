# Skill template

Fill this in for a new skill at `~/.agents/skills/<name>/SKILL.md`. Delete the
guidance comments. Keep `SKILL.md` skimmable; push depth to `references/`.

```markdown
---
name: <kebab-case-name>
description: <One or two sentences. First clause: what it does. Second: WHEN to
  use it — front-load the trigger keywords (tools, file types, symptoms) an agent
  would match on. This line is the trigger; make it specific enough to fire at the
  right moment and quiet otherwise.>
---

# <Title>

<1–3 sentence orientation: what this gets you and the shape of the workflow.>

Supporting docs live next to this SKILL.md; read them only when needed:
- `references/<x>.md` — <what and when>

## The one trap that wastes an afternoon   <!-- optional but high value -->

<The single most expensive-to-rediscover fact. Lead with it if there is one.>

## <Environment / setup>

<Copyable config or commands. A table of commands beats prose.>

| command | does |
| --- | --- |
| … | … |

## Quick diagnostics                        <!-- if the domain has failure modes -->

| symptom (log line / error) | cause | fix |
| --- | --- | --- |
| … | … | … |

## <How-to / gotchas>

<Only what generalizes. No repo names, paths, customers, or secrets.>
```

## Reference-file split

Put in a `references/*.md` (loaded on demand) anything that would bloat the main
file: long config templates, full API details, per-board pin maps, exhaustive
tables. Name them by topic. The `SKILL.md` should point to them in one line each.

## Amending an existing skill (RSI)

- Update the specific thing that was wrong; don't rewrite wholesale.
- If the skill failed to trigger when it should have, fix the `description` — that
  is usually the real bug.
- Add a new row to a diagnostics table, or a new `references/` file, rather than
  inflating the main body.
- Re-read the frontmatter after editing: does `description` still describe the
  *whole* (now-extended) skill?
