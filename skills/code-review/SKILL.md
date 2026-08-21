---
name: code-review
description: >-
  Run one adversarial, read-only review of a local diff, branch, or pull request
  and return a GitHub create-review API request with inline findings and an
  APPROVE or REQUEST_CHANGES verdict. Use when code needs an independent review
  that another process can validate or submit.
---

# Code review

Launch one independent reviewer in a real read-only sandbox. Give it the full
repository and one pinned diff. Require its only result to validate against
`github-review.schema.json`.

The highest-value rule is the boundary: **automatic tool approval is safe only
inside an enforced read-only filesystem sandbox.** A prompt that says “do not
edit” is not a sandbox. Do not give a review process write credentials, a
writable checkout, or mutating forge tools.

## Default contract

- Launch **one** fresh-context reviewer. Launch more only when the user asks for
  independent reviewers, multiple models, or distinct review lenses.
- Review the current branch plus uncommitted work unless the user gives a pull
  request, ref range, commit, path, or narrower scope.
- Pin the repository root, base ref, head ref or commit, diff command, changed
  files, repository instructions, and requirements before launch.
- Give the reviewer the full repository. A diff without surrounding code is not
  enough for call-site, integration, or convention checks.
- Set the review worktree or checkout read-only. Use a detached worktree when
  isolation from the active checkout helps. A worktree alone is not read-only.
- Use noninteractive or automatic approval only after the sandbox enforces the
  read-only boundary.
- Do not ask the reviewer to fix, build, test, install, commit, push, or submit.
- Cap inline comments at 10 unless the user gives another positive limit. This
  limit is a cap, not a quota. An approval normally has an empty `comments`
  array.

## Read-only launch

Use the harness-native structured-output option. Keep any output file outside
the reviewed repository or in runtime-owned temporary storage.

For Codex, use its enforced read-only sandbox, ephemeral session, and output
schema:

```sh
codex exec \
  --cd "$REVIEW_ROOT" \
  --sandbox read-only \
  --ephemeral \
  --output-schema /path/to/github-review.schema.json \
  "$REVIEW_PROMPT"
```

For Claude, first place the checkout in an OS, container, or runtime sandbox
that mounts it read-only. Then run print mode with automatic permissions and a
JSON Schema. Do not use `--dangerously-skip-permissions` unless the external
sandbox also denies filesystem writes, credential access, and unwanted network
access.

The process MAY use read-only inspection commands such as `git diff`, `git
show`, `git log`, `git blame`, `rg`, and file reads. It MUST NOT receive a forge
token with write permission. A separate trusted process MAY validate and submit
the returned request after explicit authorization.

If the runtime cannot enforce read-only access, do not launch the external
reviewer. Perform the review in the parent context and disclose that the result
did not come from an isolated reviewer.

## Review rules

The reviewer MUST:

1. Inspect every changed hunk and the relevant enclosing functions, callers,
   callees, error paths, state transitions, public entrypoints, and tests.
2. Report only defects introduced, exposed, or made materially harder to fix by
   the target change.
3. Check correctness, security, regressions, requirements, user-visible flows,
   test evidence, maintainability, unnecessary configuration, and reuse of
   existing libraries or project helpers.
4. Prefer the smallest correction that preserves documented behavior.
5. Attach each finding to a line in the pull-request diff. Do not invent a line
   for a repository-wide observation.
6. Include the severity, title, reasoning, consequence, and smallest safe fix in
   the inline comment `body`.
7. Return no comment for style taste, vague risk, unrelated debt, or a claim
   below 80 percent confidence.

Use these severities in the comment body:

- `P0`: Release-stopping data loss, security compromise, or systemic outage.
- `P1`: Likely wrong behavior on a primary path, or required behavior is absent.
- `P2`: An actionable defect, regression, maintainability trap, or test gap.
- `P3`: A worthwhile non-blocking follow-up. Use it rarely.

Each comment body MUST use this compact form:

```md
[P1] Short imperative title

Reasoning: Explain the trigger and why the changed code causes the problem.

Impact: State the concrete user, system, or maintenance consequence.

Fix: State the smallest safe correction.
```

Severity is part of the Markdown body because GitHub's create-review request
does not define a severity property.

## GitHub create-review output

Read `github-review.schema.json` before launch. The result MUST match the request
body for:

```text
POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews
```

Use the current pull-request head SHA as `commit_id`. Use `line` and `side` for
inline comments. Do not use the closing-down `position` field.

Use `RIGHT` for an added or unchanged line in the new file. Use `LEFT` for a
deleted line in the old file. For a multi-line comment, set `start_line` and
`start_side`; `line` and `side` identify the last line.

Set the event by evidence:

- `REQUEST_CHANGES` when at least one confirmed `P0`, `P1`, or `P2` finding must
  be fixed in this change.
- `APPROVE` when no blocking finding remains. An approval MAY include a rare
  `P3` comment, but it SHOULD normally return no comments.

The top-level `body` MUST summarize the decision and the important evidence. It
MUST NOT claim that tests passed unless the reviewer received verified results
from a trusted parent process. It SHOULD name material areas that were not
reviewed.

Example request:

```json
{
  "commit_id": "0123456789abcdef0123456789abcdef01234567",
  "body": "Request changes because the new retry path can submit a job twice.",
  "event": "REQUEST_CHANGES",
  "comments": [
    {
      "path": "src/queue.ts",
      "line": 84,
      "side": "RIGHT",
      "body": "[P1] Make retry submission idempotent\n\nReasoning: The retry path calls submit after an ambiguous timeout without an idempotency key. The first request can succeed before the timeout.\n\nImpact: One user action can create two jobs and charge twice.\n\nFix: Reuse one stable idempotency key for the initial request and every retry."
    }
  ]
}
```

## Parent validation and submission

The parent MUST validate the JSON, confirm that `commit_id` is the current PR
head, and re-read every cited diff line. It MUST drop comments that target lines
outside the diff, duplicate one root cause, describe pre-existing behavior, or
lack evidence.

Review generation is read-only. Submission is a separate mutating action. Do
not call the GitHub API or an MCP submit-review tool unless the user explicitly
authorizes submission.
