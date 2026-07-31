---
name: speckit-plan
description: Produce the technical implementation plan for a specified feature — tech stack, architecture, project structure, plus research.md, data-model.md, contracts/ and quickstart.md as needed. Use after the spec is written and clarified, before breaking work into tasks.
metadata:
  upstream: https://github.com/github/spec-kit @ d82c915
  source: templates/commands/plan.md
  license: MIT, GitHub Inc. (see ../speckit/LICENSE.upstream)
  related-skills: speckit
---

# speckit-plan

> Part of the `speckit` spec-driven development pipeline. Read `speckit` for
> the whole flow and the feature-directory convention; run
> `../speckit/scripts/feature-paths.sh --json` to resolve paths for the current
> branch.

## Outline

1. **Setup**: Run `../speckit/scripts/feature-paths.sh --require spec --json` from the repo root and parse `SPEC`, `PLAN`, `FEATURE_DIR`, and `BRANCH`. All paths it reports are absolute.

2. **Load context**: Read SPEC and `.agents/constitution.md`. Load PLAN template (already copied).

3. **Execute plan workflow**: Follow the structure in PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Re-evaluate Constitution Check post-design

## Completion Report

Command ends after Phase 1 design. Report branch, PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Define interface contracts** (if project has external interfaces) → `/contracts/`:
   - Identify what interfaces the project exposes to users or other systems
   - Document the contract format appropriate for the project type
   - Examples: public APIs for libraries, command schemas for CLI tools, endpoints for web services, grammars for parsers, UI contracts for applications
   - Skip if project is purely internal (build scripts, one-off tools, etc.)

3. **Create quickstart validation guide** → `quickstart.md`:
   - Document runnable validation scenarios that prove the feature works end-to-end
   - Include prerequisites, setup commands, test/run commands, and expected outcomes
   - Use links or references to contracts and data model details instead of duplicating them
   - Do not include full implementation code, model/service/controller bodies, migrations, or complete test suites
   - Keep this artifact as a validation/run guide; implementation details belong in `tasks.md` and the implementation phase

**Output**: data-model.md, /contracts/*, quickstart.md

## Key rules

- Use absolute paths for filesystem operations; use project-relative paths for references in documentation
- ERROR on gate failures or unresolved clarifications

## Done When

- [ ] Plan workflow executed and design artifacts generated
- [ ] Completion reported to user with branch, plan path, and generated artifacts

## Next

**Next:** `speckit-tasks` to slice the plan into independently testable work.

## Adapted from upstream

Template read from this skill's `assets/plan.template.md`; constitution read from `.agents/constitution.md`.
