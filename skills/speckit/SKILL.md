---
name: speckit
description: Spec-driven development — turn a feature idea into a spec, clarify its ambiguities, plan it, break it into user-story-sliced tasks, then implement and verify. Use to route between the speckit-* skills, or when asked about spec-driven development, SDD, or Spec Kit.
metadata:
  upstream: https://github.com/github/spec-kit @ d82c915
  license: MIT, GitHub Inc. (see LICENSE.upstream)
  related-skills: project-planning, subagent-delegation, project-notes
---

# Spec Kit — spec-driven development

Write down what a feature must do, resolve every ambiguity, plan how to build
it, slice it into independently testable work, and only then write code. The
premise is that most bad software comes from building the wrong thing
confidently, not from writing bad code — so the specification is the artifact
under version control, and the code is what falls out of it.

This is the router. Each step is its own skill; read this file to pick one.

## The pipeline

```
speckit-constitution   project principles           .agents/constitution.md   (once per project)
        │
        ▼
speckit-specify        feature idea → what & why    specs/<slug>/spec.md
        │
        ▼
speckit-clarify        hunt ambiguity, ≤5 questions specs/<slug>/spec.md      (updated in place)
        │
        ▼
speckit-plan           how to build it              specs/<slug>/plan.md + research/data-model/contracts
        │
        ▼
speckit-tasks          slice by user story          specs/<slug>/tasks.md
        │
        ├──▶ speckit-checklist   "unit tests for English"   specs/<slug>/checklists/*.md
        ├──▶ speckit-analyze     spec ↔ plan ↔ tasks drift  (read-only report)
        │
        ▼
speckit-implement      execute the task list        code
        │
        ▼
speckit-converge       what's still unbuilt?        specs/<slug>/tasks.md      (appended)
```

Steps are skippable. A small feature can go `specify` → `tasks` → `implement`.
What is *not* optional is that each step reads the artifact the previous one
wrote — every skill fails loudly rather than inventing a missing input.

## Where artifacts live

One convention, used by every `speckit-*` skill, replacing upstream's
`.specify/` project marker:

| Artifact | Path |
| --- | --- |
| Repo root | `git rev-parse --show-toplevel` |
| Feature slug | current branch minus its category prefix — `feat/user-auth` → `user-auth` |
| Feature directory | `<repo-root>/specs/<slug>/` |
| Constitution | `<repo-root>/.agents/constitution.md` |

The branch **is** the feature. There is no `feature.json`, no `SPECIFY_FEATURE`
environment variable, and no numbered `specs/001-user-auth/` scheme — the
branch already carries that state, and duplicating it into a tracked file is
how the two drift apart.

This composes with a worktree layout for free: `git rev-parse --show-toplevel`
inside a worktree returns the worktree, so a feature's specs live beside the
branch's code and disappear with it when the worktree is removed.

Run `scripts/feature-paths.sh --json` to resolve all of the above at once; it
fails with a clear message when run on a branch with no feature slug, rather
than guessing.

## When to use this instead of the alternatives

- **`speckit-*`** — *what should this feature do, and is that unambiguous?*
  Highest value when the requirements are genuinely unsettled, when several
  people must agree before code is written, or when a feature is large enough
  that discovering a misunderstanding during implementation is expensive.
- **`project-planning`** — *what lands on main, in what order?* Commits, stacked
  PRs, milestones, releases. Different axis, composes well: `speckit-tasks`
  gives the vertical slices, the projected git graph gives the landing order.
- **`subagent-delegation`** — *how does the work actually get executed?*
  Worktree per lane, `/simplify` + `/code-review` gate, land by squash-merged
  PR. `speckit-implement` hands off here for anything bigger than a single
  sitting; see that skill's Boundaries.
- **`project-notes`** — where the resulting PRs, issues, and sessions get
  recorded in the notes vault.

Skip the whole pipeline for a one-file bug fix. The ceremony costs more than
the bug.

## Attribution

Adapted from [github/spec-kit](https://github.com/github/spec-kit) (commit
`d82c915`), MIT licensed — see `LICENSE.upstream`. This is not a stock Spec Kit
install; see each skill's Adapted-from note. The main divergences:

- The `specify` CLI, `.specify/` scaffolding, extension registry, hook protocol,
  and bundle system are gone. Skills are invoked directly.
- Feature state comes from the git branch instead of `.specify/feature.json`.
- `speckit-taskstoissues` was not imported — `project-notes` and `git-forge`
  already own issue creation.

If a project ever runs `specify init` for real, it writes `speckit-*` skills
into that project's `.agents/skills/`, which take precedence over these. That
is the intended outcome: a genuine Spec Kit install, with a genuine `.specify/`
directory, should win over this adaptation.
