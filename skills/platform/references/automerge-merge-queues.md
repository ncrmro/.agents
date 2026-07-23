# Auto-merge and merge queues

How to make a repository land agent (and human) PRs automatically once CI passes,
so a delegated worker can `gh pr merge --squash --auto` and walk away. Two
independent GitHub features stack here: **auto-merge** (merge this PR when its
gates go green) and a **merge queue** (serialize + re-test PRs against the latest
base before merging). Auto-merge alone is enough for low-traffic repos; add a
merge queue when concurrent merges would otherwise land against a stale base.

Keep repo-specific values (names, required check names) out of shared `.agents`
content — document the *procedure* here; the concrete settings live in each
consuming repository.

## Prerequisites for `gh pr merge --auto`

Auto-merge only takes effect when **all three** hold:

1. **Auto-merge is enabled on the repository.** Settings → General → Pull
   Requests → "Allow auto-merge", or via API:
   ```sh
   gh api -X PATCH repos/{owner}/{repo} -f allow_auto_merge=true
   ```
2. **The branch is protected with at least one required gate** — a required
   status check or required review. With no gate there is nothing to wait on, and
   GitHub rejects the auto-merge request.
3. **The chosen merge method is allowed** (`--squash` needs "Allow squash
   merging" on). Match the flag to the repo's allowed methods.

Then:
```sh
gh pr merge <number> --squash --auto        # queue for merge when gates pass
gh pr merge <number> --squash --auto --delete-branch
```
`--auto` is a request, not an immediate merge: it merges only after required
checks succeed (and, if configured, the PR passes through the merge queue).

## Branch protection / rulesets (the gate)

Auto-merge needs required checks. Prefer **repository rulesets** (the current
model) over classic branch protection. A minimal ruleset targeting the default
branch:

- Require a pull request before merging (optionally N approvals; agent PRs from a
  bot identity may need a human or a second bot — see the `agent-git-forge`
  concept for who can approve).
- Require status checks to pass; list the CI job names that must be green.
- Optionally "Require branches to be up to date before merging" — but on a busy
  repo prefer a merge queue over this, which otherwise forces serial rebasing.

Via API (skeleton — fill in real check names per repo):
```sh
gh api -X POST repos/{owner}/{repo}/rulesets \
  -f name='default-branch' -f target='branch' -f enforcement='active' \
  -f 'conditions[ref_name][include][]=~DEFAULT_BRANCH' \
  -f 'rules[][type]=pull_request' \
  -f 'rules[][type]=required_status_checks'
```
Inspect what a required check is actually named (must match exactly) with:
```sh
gh pr checks <number>
gh api repos/{owner}/{repo}/commits/{sha}/check-runs --jq '.check_runs[].name'
```

## Merge queue (serialize + re-test)

A merge queue batches approved PRs, re-runs required checks against the *result*
of merging them in order, and merges each only if that combined state passes —
eliminating "green PR breaks main because base moved" without serial manual
rebasing.

- Enable in the ruleset: add the **"Require merge queue"** rule to the default
  branch, and set the merge method (squash) + batch size there.
- CI must trigger on the `merge_group` event so the queue's synthetic branch gets
  tested, e.g.:
  ```yaml
  on:
    pull_request:
    merge_group:
  ```
  Without a `merge_group` trigger, required checks never report on the queue's
  branch and PRs stall in the queue.
- With a queue enabled, `gh pr merge --auto` adds the PR to the queue instead of
  merging directly; the queue does the final merge.

## Verifying

```sh
gh api repos/{owner}/{repo} --jq '.allow_auto_merge, .allow_squash_merge'
gh pr view <number> --json autoMergeRequest,mergeStateStatus
gh api repos/{owner}/{repo}/rulesets --jq '.[].name'
```
`mergeStateStatus` of `BLOCKED` usually means a required gate is unmet or
auto-merge is off; `CLEAN`/`HAS_HOOKS` means it will merge when checks pass.
