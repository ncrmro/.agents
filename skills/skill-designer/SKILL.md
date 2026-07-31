---
name: skill-designer
description: Design, create, validate, and maintain Pi Agent Skills. Use when authoring a new SKILL.md, improving an existing skill, choosing global versus project skill placement, or checking Agent Skills frontmatter and discovery rules.
metadata:
  source-of-truth: https://pi.dev/docs/latest/skills
---

# Skill designer

Create Pi skills as small, triggerable capability packages: a precise `SKILL.md`, optional helper files, and enough workflow detail that the next agent starts at the hard-won solution instead of rediscovering it.

Source of truth: <https://pi.dev/docs/latest/skills>. Re-check it when frontmatter, discovery, or validation behavior matters; this skill records the current operating baseline, not a replacement for the docs.

## Default placement

Default to the personal catalog:

```text
~/.agents/skills/<skill-name>/SKILL.md
```

Use project-local `.agents/skills/<skill-name>/SKILL.md` only when the skill is repo-specific and should load only after the project is trusted. Use `~/.pi/agent/skills/` or `.pi/skills/` only when the caller explicitly wants Pi-only placement or direct root `.md` skill discovery.

Pi discovers:

- Global skills from `~/.pi/agent/skills/` and `~/.agents/skills/`.
- Project skills from `.pi/skills/` and `.agents/skills/` in the cwd or ancestors, after project trust.
- Package skills from `skills/` directories or `pi.skills` package metadata.
- Settings and CLI skills from `skills` settings entries and repeatable `--skill <path>`.

Important asymmetry: root `.md` files are discovered only in `~/.pi/agent/skills/` and `.pi/skills/`; root `.md` files under `.agents/skills/` are ignored. For `~/.agents`, always create a directory containing `SKILL.md`.

## Creation loop

1. **Clarify scope only if it changes placement or safety.** Personal reusable workflow → `~/.agents/skills`. Repo-specific workflow → project `.agents/skills`. Executable helpers or risky instructions → mention the review requirement.
2. **Search first.** Check existing skill names and descriptions; amend an existing owner when possible. Duplicate skills rot and collide.
3. **Pick a valid name.** Use lowercase `a-z`, digits, and hyphens; 1–64 chars; no leading/trailing hyphen; no `--`. Pi does not require the directory name to match, but matching keeps humans sane.
4. **Write frontmatter.** Required: `name`, `description`. Optional: `license`, `compatibility`, `metadata`, `allowed-tools`, `disable-model-invocation`.
5. **Make the description do trigger work.** It MUST say what the skill does and when to use it, in concrete task/tool/domain words. Keep under 1024 chars. A missing description means Pi will not load the skill.
6. **Keep `SKILL.md` skimmable.** Put the primary workflow, gotchas, diagnostics, and references there. Move long tables, specs, API notes, prompts, templates, and examples to `references/`.
7. **Use relative paths.** Refer to helper scripts and references relative to the skill directory, e.g. `references/api.md` or `scripts/check.sh`.
8. **Validate.** Re-read the file, check frontmatter, and list the path. If the skill includes scripts, inspect them before use and make invocation commands explicit.

## `SKILL.md` template

```markdown
---
name: <kebab-case-name>
description: <What this skill does. Use when <specific trigger tasks, tools, files, or symptoms>.>
---

# <Human title>

<One short paragraph: outcome, scope, and the shape of the workflow.>

Supporting docs, loaded only when needed:
- `references/<topic>.md` — <when to read it>

## Default decision

<The highest-leverage rule, default, or trap. Put the afternoon-saving fact first.>

## Workflow

1. <Concrete step.>
2. <Concrete step.>
3. <Validation step.>

## Validation

- MUST <checkable condition>.
- SHOULD <secondary quality bar>.

## Diagnostics

| symptom | likely cause | fix |
| --- | --- | --- |
| <error or smell> | <cause> | <action> |
```

## Description quality bar

Good:

```yaml
description: Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents.
```

Bad:

```yaml
description: Helps with PDFs.
```

The description is the skill's routing surface. Front-load nouns and verbs an agent will match: file types, tools, APIs, workflows, failures, and outcomes.

## Validation checklist

Before calling a skill done:

- MUST exist at `~/.agents/skills/<name>/SKILL.md` unless another location was explicitly requested.
- MUST have YAML frontmatter with `name` and `description`.
- MUST use a valid skill name: lowercase letters, numbers, hyphens; 1–64 chars; no edge hyphens; no consecutive hyphens.
- MUST keep `description` under 1024 chars and specific enough to trigger correctly.
- MUST avoid secrets, credentials, private customer facts, and one-off project memory.
- MUST review executable helper scripts before relying on them; skills can direct powerful actions.
- SHOULD cite or record the upstream source when encoding current Pi behavior.
- SHOULD split bulky detail into `references/` and keep `SKILL.md` useful in the first screen.

## Maintenance

When updating a skill, prefer small amendments over rewrites. If it failed to trigger, fix `description`; if it had stale mechanics, source-check the Pi docs; if it grew too large, split references. Name collisions warn and keep the first discovered skill, so resolve duplicate names intentionally rather than relying on load order.
