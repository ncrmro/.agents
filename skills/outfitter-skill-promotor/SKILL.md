---
name: outfitter-skill-promotor
description: Promote one local Agent Skill from ~/.agents/skills into the Outfitter community-profiles catalog through a reviewed GitHub pull request. Use when a user asks to contribute, publish, or promote a personal skill to the Outfitter community.
---

# Outfitter skill promotor

Promote one complete local skill package. Preserve its files, test it in the
community catalog, and open a draft pull request.

## Protect the package boundary

A local skill can contain symlinks, secrets, or project-specific data. Do not
copy the package until you inspect every file.

The source MUST be one direct child of `~/.agents/skills/`. Its directory name
MUST match the `name` field in `SKILL.md`. Reject a source that contains a
symlink, a Git directory, a credential, a generated artifact, or a file that
does not support the skill.

Do not change the local skill during promotion. If the source needs changes,
stop and update the local skill first.

## Inputs

Get these values from the request or from the local environment:

- `skill`: The local skill slug.
- `repository`: The community catalog checkout. Use
  `ai-outfitter/community-profiles` unless the user specifies another fork.
- `base`: The pull request base branch. Use the remote default branch.

## Workflow

1. Read the applicable `AGENTS.md` files.
2. Resolve `~/.agents/skills/<skill>` to its real path.
3. Confirm that the source is a direct child of the personal skills directory.
4. Read the complete source package.
5. Compare the skill with the target catalog and its open pull requests.
6. Stop if the catalog already contains the skill or an equivalent skill.
7. Confirm GitHub authentication and the target repository.
8. Fetch the remote default branch.
9. Create a semantic worktree and branch named
   `feat/promote-<skill>`.
10. Copy the complete package to `skills/<skill>/`.
11. Add the skill to the catalog README.
12. Review `git diff` and `git status`.
13. Run the checks in [Validation](#validation).
14. Commit only the promoted package and its README entry.
15. Push the branch.
16. Open a draft pull request.
17. Read the pull request back and return its canonical URL.

Use `git worktree list` as the source of truth. Reuse a matching worktree only
when its branch and purpose match this promotion.

## Validation

Run all checks from the community catalog worktree:

```sh
git diff --check
outfitter validate --strict
```

Run each test script in the promoted package:

```sh
for test_file in skills/<skill>/scripts/*.test.sh skills/<skill>/tests/*.test.sh
do
  test -e "$test_file" || continue
  bash "$test_file"
done
```

Use the repository dev shell when its instructions require one. Do not install
tools globally. If the repository cannot provide `outfitter`, report that
validation gap in the pull request.

Inspect the staged file list before the commit:

```sh
git diff --cached --name-only
```

The list MUST contain only `skills/<skill>/` and the catalog README.

## Pull request

Use a semantic title:

```text
feat(<skill>): add community skill
```

The body MUST contain:

- the skill purpose and trigger;
- the source path;
- all validation results;
- the intended supported harnesses;
- any files or checks that need maintainer attention.

Open the pull request as a draft. A maintainer can then review the package
before release.

## Stop conditions

Stop and ask the user before you continue when:

- the source package contains a possible secret or personal record;
- the source license or authorship does not permit publication;
- an equivalent community skill exists;
- the target branch contains unrelated changes;
- validation changes files outside the promoted package;
- the push or pull request targets a repository other than the confirmed
  repository.
