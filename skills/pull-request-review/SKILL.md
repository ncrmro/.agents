---
name: pull-request-review
description: Inspect a GitHub pull request against its intended base, produce exact file-and-line findings plus an overall assessment, and submit one human-style GitHub review. Use when Codex is asked to review a PR, compare a milestone or feature branch with its base, turn local review findings into inline PR comments, or post/submit review feedback rather than merely summarize it.
---

# Pull Request Review

Submit one coherent review whose inline anchors, commit, and overall conclusion
match the current pull request.

## Workflow

1. Resolve the repository and pull request from the supplied URL/number or the
   current branch. Record the PR number, base branch, head branch, head SHA,
   author, authenticated user, and draft/open state.
2. Read repository instructions and any planning, requirement, or milestone
   sources that define the requested scope. For milestone branches, review the
   complete `base...head` diff and success criteria, not only the latest commit.
3. Fetch the current PR diff, submitted reviews, inline threads, and top-level
   comments. Prefer the GitHub connector; use `gh` when the connector lacks
   access or thread/diff fidelity. Do not duplicate an existing substantive
   finding.
4. Inspect and verify the change locally. Run checks proportional to the risk
   and reproduce suspected failures when practical. Report only defects
   introduced or exposed by the PR.
5. Draft a review specification as JSON:

```json
{
  "action": "REQUEST_CHANGES",
  "commit_id": "<current PR head SHA>",
  "review": "<overall review body>",
  "comments": [
    {
      "path": "path/from/repository/root",
      "line": 42,
      "side": "RIGHT",
      "body": "**[P1] Short imperative title**\n\nTrigger, impact, and requested correction."
    }
  ]
}
```

6. Generate a zero-context patch for anchor validation:

```bash
git diff --unified=0 <base>...<head> > /tmp/pr-review.patch
python scripts/validate_review.py \
  --diff /tmp/pr-review.patch \
  --review /tmp/pr-review.json \
  --head-sha <current-head-sha>
```

7. Re-fetch the PR head immediately before submitting. Stop and rebuild the
   review if the SHA changed.
8. Submit all inline comments and the overall body in one review operation.
   Use `REQUEST_CHANGES` for blocking defects, `COMMENT` for non-blocking
   feedback, and `APPROVE` only when no actionable defects remain. GitHub does
   not allow authors to request changes on their own PR; when the authenticated
   user is the PR author, use `COMMENT` and state clearly that the findings are
   blocking.
9. Fetch the submitted review and threads after submission. Verify the review
   event, head SHA, overall body, inline-comment count, paths, lines, and bodies.
   Prefer GraphQL `reviewThreads` for anchor verification: GitHub's bulk REST
   review-comment list may expose only legacy `position` fields even when each
   individual comment has a modern `line`/`side` anchor. Treat a partial
   submission as incomplete.

## Inline comment rules

- Anchor each finding on an added `RIGHT`-side line that best represents the
  defect. Put branch-wide or missing-work findings in the overall review when
  no honest inline anchor exists.
- Use one comment per independent root cause. Combine symptoms that require the
  same correction; split findings that can be fixed independently.
- State the concrete trigger and consequence. Avoid vague preferences,
  compliments, implementation narration, or a second summary inside every
  comment.
- Use `[P0]` for release-stopping emergencies, `[P1]` for materially incorrect
  behavior or a milestone-blocking omission, and `[P2]` for normal actionable
  defects. Do not inflate severity.
- Keep code suggestions optional and small. Ask for the behavior or invariant,
  not an unnecessarily specific rewrite.

## Overall review rules

- Lead with the decision and the dominant risk.
- Summarize clusters instead of repeating every inline comment.
- Include verification performed and any important unverified area.
- Identify branch-wide milestone gaps that cannot be attached to one changed
  line.
- Never claim that comments were submitted until the post-submit read proves
  it.

## Write safety

- PR inspection is read-only. Submission is an external write and requires an
  explicit user request.
- Never submit from stale local findings without checking the current remote
  head and existing threads.
- Prefer one atomic review. Do not post loose issue comments as a substitute
  for inline review comments.
- If exact anchors cannot be validated, keep the findings in the overall review
  rather than guessing line positions.
