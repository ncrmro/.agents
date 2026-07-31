---
name: speckit-implement
description: Execute a feature's tasks.md — work the phases in order, respect [P] parallel markers, mark tasks [X] as they complete. Use once tasks exist and their checklists pass. For anything larger than a single sitting, hand off to subagent-delegation instead.
metadata:
  upstream: https://github.com/github/spec-kit @ d82c915
  source: templates/commands/implement.md
  license: MIT, GitHub Inc. (see ../speckit/LICENSE.upstream)
  related-skills: speckit
---

# speckit-implement

> Part of the `speckit` spec-driven development pipeline. Read `speckit` for
> the whole flow and the feature-directory convention; run
> `../speckit/scripts/feature-paths.sh --json` to resolve paths for the current
> branch.

## Outline

1. Run `../speckit/scripts/feature-paths.sh --require tasks --json` from the repo root and parse `FEATURE_DIR`, `TASKS`, and `AVAILABLE_DOCS`. All paths it reports are absolute.

2. **Run the implementation gate.** Follow the Gate section of `speckit-checklist`:
   tally `FEATURE_DIR/checklists/`, and on FAIL stop and ask before going further.
   Nothing to tally means nothing to gate — continue.

3. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read `.agents/constitution.md` for governance constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

5. Execute implementation following the task plan:
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding

6. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

7. Progress tracking and error handling:
   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

8. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running ``speckit-tasks`` first to regenerate the task list.

## Completion Report

Report final status with summary of completed work.

## Done When

- [ ] All tasks in tasks.md completed and marked `[X]`
- [ ] Implementation validated against specification, plan, and test coverage
- [ ] Completion reported to user with summary of completed work

## Boundaries

This skill executes tasks **in the current working tree, in one sitting**. That
is the right shape for a feature small enough to finish now.

Hand off to `subagent-delegation` instead when the task list is large, when
`[P]` lanes should genuinely run in parallel, or when the work wants a PR per
lane. That skill owns the execution model this repo actually uses — a worktree
cut from `origin/main` per lane, the `/simplify` + `/code-review` gate, and
landing by squash-merged PR — and it supersedes steps 5–8 of the Outline entirely.
Bring `tasks.md` along as the queue; one lane per user-story phase.

Do not run both. Two execution models over one working tree is how a feature
ends up half-landed.

## Next

**Next:** `speckit-converge` to find work the spec implies but the code does not yet have.

## Adapted from upstream

Upstream's 40-line hardcoded per-language `.gitignore` pattern table (step 4) was removed — it is unrelated to spec-driven development and duplicates what any project already has. The checklist gate (upstream step 2) now lives in `speckit-checklist`, which this skill calls.
