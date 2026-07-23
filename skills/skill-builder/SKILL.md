---
name: skill-builder
description: Capture hard-won, reusable domain knowledge into a new skill, or amend an existing skill when it was incomplete, wrong, or out of date. Use proactively whenever a task surfaced a non-obvious gotcha, a multi-step workflow that took iteration to get right, a toolchain trap, or a correction the user made — and whenever you just relied on a skill that let you down. Offer to capture; don't create without a yes.
---

# Skill builder (capture + self-improve)

Turn knowledge earned the hard way into a durable skill so the next agent (or the
next you) starts where this task ended. Two modes: **capture** new knowledge into
a new skill, and **RSI** — amend an existing skill you just found lacking.

## Recognize the moment (when to offer)

Reach for this skill when, during real work, you hit any of:

- A **non-obvious gotcha** that cost real time — a toolchain trap, an env quirk, a
  wrong-by-default setting, an API that moved. (If you thought "I'll remember that
  it's actually X, not Y" — capture it.)
- A **multi-step workflow** you only got right after iterating (setup, build,
  flash, deploy, diagnose…). The working sequence + the dead ends are the value.
- A **diagnostic map** you built: symptom → cause → fix (a table of failure modes).
- A **user correction** that encodes a standard ("use X not Y", "always do Z
  first"). Corrections are high-signal skill material.
- You just **used a skill and it was wrong/incomplete/stale** → go straight to RSI
  (amend it), and fix its `description` if that's why it didn't trigger.

Do **not** capture: one-off project facts, secrets, or anything tied to a single
repo/customer — those go to **memory**, not a skill (see "Skill vs memory").

## The loop

1. **Notice** a signal above (usually at a natural stopping point, not mid-task).
2. **Offer, once, concretely** — don't auto-create and don't nag. Propose:
   *"Worth a skill? I'd add `<name>` — '<one-line description>' — covering
   <2–4 bullets>. Create it / add it to `<existing-skill>` / skip?"*
3. On yes: **write or amend** (below). On "add to X": prefer amending an existing
   skill over a near-duplicate.
4. Keep the **`description` accurate** — it's the trigger. Say both *what it does*
   and *when to use it* in one or two sentences, front-loaded with keywords.

## New vs amend

- Search the catalog first. If a skill already owns the topic, **amend** it —
  update the trap, extend a table, add a reference file. Duplicates rot.
- New skill only for a genuinely new domain/tool. One skill = one coherent area.

## Skill anatomy

- Location: the personal catalog under `~/.agents/skills/`. One directory per
  skill.
- `SKILL.md` with frontmatter `name` + `description`, then a scannable body.
- Heavy detail → `references/*.md` next to `SKILL.md`, loaded on demand; keep
  `SKILL.md` itself skimmable. Copy-paste templates and command tables earn their
  place; prose doesn't.
- **Lead with the single highest-leverage thing** (the "one trap that wastes an
  afternoon"), then environment/workflow, then a diagnostics table.
- **Project-agnostic**: no repo names, customer names, machine paths, or
  credentials. Generalize the specifics from the task that taught you.
- See `references/skill-template.md` for a fill-in starting point.

## Skill vs memory (don't confuse them)

| goes in a **skill** | goes in **memory** |
| --- | --- |
| reusable, project-agnostic *how-to* / domain knowledge | facts about *this* user, project, or repo |
| a workflow, a gotcha, a diagnostic table | a decision made, a path, a preference, a deadline |
| survives across all repos | scoped to your work here |

If a lesson has both a general half and a project-specific half, split it: the
general half → skill, the specific half → memory, and cross-reference.

## Quality bar before you commit it

- Would this save the next agent real time on a *different* project? If no, it's
  memory, not a skill.
- Is the `description` specific enough to fire at the right moment and not others?
- Did you strip every project/secret specific?
- Is the highest-value lesson in the first screen?
