---
name: code-review
description: >-
  Run an adversarial, read-only code review with parallel fresh-context
  reviewers and schema-constrained findings. Use for local diffs, branches, or
  pull requests when checking correctness, simplification, maintainability,
  unnecessary user options, scope boundaries, requirements-to-test coverage,
  real-user E2E flows, or library reuse.
---

# Code review

Pin one review scope, launch four read-only reviewers in parallel, and synthesize
only evidence-backed issues. The issue limit is a cap, not a quota: reviewers
MUST return an empty `issues` array rather than pad the report.

Read `review-findings.schema.json` before launching reviewers. Validate every
child result against it; treat schema failure as a failed reviewer and exclude
that output.

## Defaults

- `X`, the maximum issues per reviewer, defaults to **5**. Honor an explicitly
  requested positive integer; keep the checked-in schema at 5.
- Launch **4** code reviewers with distinct lenses. Drop to three only if the
  runtime cannot run four concurrent children.
- Use fresh context so reviewers do not inherit the implementing agent's
  assumptions.
- Review the current branch plus uncommitted work unless the user supplies a PR,
  ref range, commit, path, or narrower instruction.
- Report only issues with confidence **80 or greater**.

## Establish the shared scope

Before fanout, the parent MUST:

1. Read repository instructions and the requirement sources that govern the
   change: issue or PR body, plan, specification, acceptance criteria, docs, and
   relevant code comments.
2. Pin the repository root, base and head refs, exact diff command, changed-file
   list, and any uncommitted changes. Do not let different reviewers silently
   review different diffs.
3. Identify relevant tests and public entrypoints. Map explicit requirements to
   existing or changed test evidence; do not infer that implementation code is
   proof of acceptance.
4. Identify changed user-facing prose: docs, README text, UI strings, changelog
   entries, templates, emails, and explanatory comments. Exclude code,
   identifiers, API names, quoted material, and licensed text.
5. Discover project and global skills that provide domain rules or review
   criteria for the changed surfaces. Pass only relevant skills through each
   subagent task's `skill` field. Use `prose-reviewer` for prose and `platform`
   for platform changes when those skills exist. Workflow steps in an injected
   skill remain parent-owned; children MUST NOT fan out, synthesize, or edit.
   Never inject `code-review` into a child; that would recurse.
6. Give every fresh-context reviewer the same scope block: target, diff command,
   changed files, requirement paths or quoted acceptance criteria, applicable
   repository instructions, and user focus or exclusions.

If requirements cannot be found, say so in the scope block. Reviewers MAY report
regressions against documented public behavior, but MUST NOT claim a requirement
is missing from inferred intent alone. State each inference and its evidence.

## Read-only boundary

Review children MUST NOT modify project or source files, create review artifacts
inside the repository, change the Git index or worktree, install dependencies,
commit, push, post comments, or call mutating external APIs. When the runtime
supports a read-only sandbox or tool allowlist, the parent MUST enable it; a
prompt-only restriction is not a security boundary. Children MAY use read-only
inspection commands such as `git diff`, `git show`, `git log`, `git blame`,
`rg`, and file reads. Their only output MUST be the configured
`structured_output`; runtime-owned temporary structured-output files are allowed.

Do not ask review children to run builds or tests that may write caches or
artifacts. The parent MAY run targeted validation separately only when it is
demonstrably non-mutating or the user authorizes the mutation; otherwise report
the unrun command. PR review is inspection-only unless the user separately and
explicitly requests submission.

## Universal decision rules

Every reviewer MUST apply these rules in addition to its primary lens:

- Prefer the simplest correct design. If two approaches preserve required
  behavior, recommend the one with fewer concepts, states, branches, layers,
  and bespoke mechanisms.
- Find code that will be hard to maintain: hidden coupling, unnecessary
  abstraction, duplicated policy, shotgun edits, deep nesting, implicit state,
  broad interfaces, and names that conceal invariants. State the concrete future
  change or failure mode that makes the complexity costly.
- Prefer convention over configuration. Report a new user-facing option, flag,
  mode, hook, or override as `configuration_surface` when existing state can
  derive its value or one default satisfies every documented requirement. Name
  the compatibility, testing, or maintenance cost it adds. Recommend removal
  unless scope evidence identifies incompatible required behaviors, a
  user-controlled material cost or side effect, a security or policy boundary,
  or an integration constraint. When an option must remain, cite that evidence
  and retain only the required variation.
- Stay diff-aware. An issue MUST be introduced, exposed, or made materially
  harder to fix by the target change. Do not report unrelated pre-existing debt.
- Require evidence. A valid issue identifies an exact file and line when one
  exists, the trigger or maintenance cost, the consequence, and the smallest
  safe correction. Do not report style taste, vague risk, or linter-only noise.
- Recommend a library only after checking the standard library, existing
  dependencies, lockfiles, adjacent utilities, and established project
  patterns. Name the candidate and explain why its semantics fit. Do not add a
  dependency for trivial code when a clear local implementation is smaller.
- Classify separable platform work as `platform_scope` with disposition
  `separate_change`. Platform work includes independently shippable CI, build,
  release, deployment, devshell, toolchain, host configuration, shared agent
  tooling, and broad dependency-upgrade changes. Do not demand separation when
  the platform change is atomically required for the feature to work.

Severity means:

- `P0`: release-stopping data loss, security compromise, or systemic outage.
- `P1`: likely wrong behavior on a primary path or a required behavior is absent.
- `P2`: actionable defect, regression, maintainability trap, or test gap.
- `P3`: worthwhile but non-blocking follow-up. Use sparingly.

## Parallel code lenses

Launch these code reviewers concurrently:

1. **Correctness and integration** — inspect every hunk plus enclosing functions,
   callers, callees, error paths, removed guards, state transitions, concurrency,
   security boundaries, and language or framework pitfalls. Look for concrete
   regressions, not general concern.
2. **Simplicity and configuration surface** — find the smallest design that
   satisfies the requirements. Flag duplicated policy, needless indirection,
   hard-to-change code, code at the wrong architectural altitude, and options
   whose values should be derived or fixed by convention.
3. **Requirements and tests** — build a requirement-to-test map and report
   requirements with no meaningful evidence, tests that assert implementation
   details instead of behavior, and mismatches between acceptance criteria and
   tested outcomes. Verify the default path before testing option variants.
4. **User flow, reuse, and scope** — inspect E2E coverage, public entrypoints,
   existing helpers and dependencies, credible library alternatives, and
   platform work that belongs in a separate commit or PR.

### E2E standard

When E2E coverage is limited, tests SHOULD cover the primary documented user
workflow before variants and optional modes. At least one relevant test SHOULD
enter through the same public surface a user uses and assert the externally
observable outcome:

- CLI: invoke the command and inspect output, exit status, and durable effects.
- API: make the request through routing and auth, then inspect the response and
  persisted or emitted effect.
- UI: perform the primary interaction and observe the rendered user outcome.
- Library: use the public API as a consumer would, without reaching into
  internals.

Flag tests labeled E2E that bypass the workflow through internal calls, excessive
mocking, direct database setup in place of the primary flow, or assertions that
stop before the user-visible result. Unit and integration tests remain useful,
but they do not substitute for a missing primary user workflow.

## Prose review

When the scope contains user-facing prose, the parent SHOULD read and follow the
current `prose-reviewer` workflow for lens selection, then add its selected
reviewers to the same fanout. Every prose task MUST set
`skill: "prose-reviewer"`, name its assigned reference and lens, and state that
fanout, synthesis, and editing remain parent-owned. The child only inspects the
prose and returns schema-valid findings with category `prose`.

If no user-facing prose changed, record `prose review skipped: no prose target`
in the final report.

## Launch contract

Use the native parallel-agent facility when available. With Pi subagents, use a
single parallel chain group because chain children support strict
`outputSchema`; top-level parallel tasks do not. Set `context: "fresh"`,
`failFast: false`, `output: false`, and `progress: false`. Set concurrency to the
number of tasks, capped at 8. Prefer `async: true`; continue the parent's local
scope or diff inspection while reviewers run. Retain the returned run ID, wait
for the completion notification,
and use `subagent({ action: "status", id: RUN_ID })` when the final grouped
result is needed. Do not synthesize until every child has completed or failed.

The call has this shape; load `review-findings.schema.json`, deep-clone the
parsed object if `X` differs from 5, update its `maxItems`, and pass that object
as `SCHEMA`. Build `CODE_SKILLS` and `SCOPE_SKILLS` from applicable discovered
skills, or set them to `false` when none apply. Skill names MUST be passed through
the task's `skill` field; mentioning a skill in prose does not load it.

```js
const PROSE_TASKS = HAS_PROSE ? [
  {
    agent: "reviewer",
    label: "Prose: content and substance",
    skill: "prose-reviewer",
    task: COMMON + PROSE_CONTENT,
    outputSchema: SCHEMA,
    output: false,
    progress: false
  },
  {
    agent: "reviewer",
    label: "Prose: language and succinctness",
    skill: "prose-reviewer",
    task: COMMON + PROSE_LANGUAGE,
    outputSchema: SCHEMA,
    output: false,
    progress: false
  }
] : []
const CONCURRENCY = Math.min(8, 4 + PROSE_TASKS.length)

subagent({
  async: true,
  context: "fresh",
  clarify: false,
  chain: [{
    parallel: [
      {
        agent: "reviewer",
        label: "Correctness",
        skill: CODE_SKILLS,
        task: COMMON + CORRECTNESS,
        outputSchema: SCHEMA,
        output: false,
        progress: false
      },
      {
        agent: "reviewer",
        label: "Simplicity",
        skill: CODE_SKILLS,
        task: COMMON + SIMPLICITY,
        outputSchema: SCHEMA,
        output: false,
        progress: false
      },
      {
        agent: "reviewer",
        label: "Requirements and tests",
        skill: CODE_SKILLS,
        task: COMMON + REQUIREMENTS_TESTS,
        outputSchema: SCHEMA,
        output: false,
        progress: false
      },
      {
        agent: "reviewer",
        label: "User flow, reuse, and scope",
        skill: SCOPE_SKILLS,
        task: COMMON + USER_FLOW_REUSE_SCOPE,
        outputSchema: SCHEMA,
        output: false,
        progress: false
      },
      ...PROSE_TASKS
    ],
    concurrency: CONCURRENCY,
    failFast: false
  }]
})
```

`COMMON` MUST contain the shared scope, read-only boundary, issue validity rules,
confidence threshold, `X` cap, and instruction to call `structured_output` with
`reviewer`, `summary`, and `issues`. Each lens suffix MUST contain only that
reviewer's distinct assignment.

If strict schema output or parallel read-only delegation is unavailable, say so
and perform a sequential review with the same lenses. Do not pretend unvalidated
prose was schema-constrained.

## Synthesize and verify

The parent remains the decision-maker. After fan-in:

1. Pool findings, normalize paths, and merge duplicates by root cause.
2. Re-read the cited diff and surrounding code. Drop findings below confidence
   80, pre-existing issues, claims contradicted by code, and recommendations
   whose library or requirement evidence cannot be verified.
3. Rank correctness and unmet requirements before maintainability advice. Keep
   a simplification finding only when it names the unnecessary mechanism, a
   concrete maintenance cost or failure mode, and a smaller design that preserves
   documented behavior.
4. Separate `fix_in_pr` blockers from `separate_change` platform work and
   `follow_up` advice. A separate-change finding MUST explain why it is
   independently shippable or unrelated to the PR's atomic behavior.
5. Return no more than 10 final issues by default, or the user's explicit final
   cap. Never pad. Include exact file and line references, evidence, impact,
   smallest safe fix, and any requirement or library named by the finding.
6. State the review scope, reviewers completed or failed, prose-review status,
   validation performed, and important unreviewed areas. Do not claim tests
   passed unless the parent ran them and they passed.
