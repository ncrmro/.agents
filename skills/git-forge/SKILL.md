---
name: git-forge
description: Inspect and manipulate GitHub and Forgejo repositories through their authenticated APIs and CLIs. Use for repository and project-management operations, especially when choosing between GitHub connectors/gh and Forgejo tea/API workflows.
---

# Git Forge

Use the forge that owns the target repository. Before changing remote state,
confirm the host, repository or project, target item, and authenticated account.

## Choose the interface

- For GitHub, prefer an installed GitHub connector when it supports the
  operation. Use `gh` for local-repository context, GitHub Actions logs,
  GraphQL, GitHub Projects v2, or operations the connector does not expose.
- For Forgejo, use `tea` for operations exposed by the installed version. Check
  `tea --help` before assuming a first-class command exists.
- Use `tea api` for Forgejo features without a first-class `tea` subcommand,
  including project-board operations supported by the server API.
- Prefer a first-class `gh` or `tea` command when one exists. Use GraphQL only
  when GitHub's REST API and CLI cannot express the operation.

Do not treat Forgejo as GitHub merely because both accept Actions-style
workflow syntax. Their APIs, identity claims, permissions, and project models
may differ.

## Inspect before writing

1. Inspect remotes with `git remote -v` when working from a checkout.
2. Confirm GitHub authentication with `gh auth status`. For Forgejo, inspect
   configured accounts with `tea login list`, then make a read-only API request
   to confirm the selected credentials work.
3. Read the target and any metadata the mutation depends on.
4. Search for an existing equivalent item before creating one.
5. State the exact target and intended mutation.
6. Perform only the user-authorized write.
7. Read the result back and return its canonical URL.

Authorization to inspect or comment does not authorize destructive, release,
visibility, protection, or unrelated project changes.

## GitHub

Use repository-qualified commands when the current checkout is absent or
ambiguous:

```bash
gh issue list --repo OWNER/REPO --state all
gh issue create --repo OWNER/REPO --title "TITLE" --body-file BODY.md
gh pr view NUMBER --repo OWNER/REPO
gh api repos/OWNER/REPO
```

For GitHub Projects v2, distinguish the project owner from a repository. A
project belongs to a user or organization and may contain items from several
repositories:

```bash
gh project list --owner OWNER
gh project view NUMBER --owner OWNER
gh project field-list NUMBER --owner OWNER
gh project item-list NUMBER --owner OWNER
gh project item-add NUMBER --owner OWNER --url ISSUE_OR_PR_URL
```

Project mutations require the `project` token scope. Inspect project and field
IDs before calling `gh project item-edit`; do not guess IDs or single-select
option values.

Use `gh api graphql` when a Projects v2 mutation is unavailable from
`gh project`. Immediately before the mutation, fetch every required project,
item, field, and option ID.

## Forgejo

Select the configured login and qualify the repository when context is
ambiguous:

```bash
tea login list
tea issues ls --repo OWNER/REPO --state all
tea issues create --repo OWNER/REPO --title "TITLE" --description "BODY"
tea pulls show --repo OWNER/REPO NUMBER
tea api --repo OWNER/REPO '/repos/{owner}/{repo}'
```

`tea api` prefixes relative endpoints with `/api/v1/` and substitutes
`{owner}` and `{repo}` from repository context. Quote endpoints containing `?`
or `&`. Use `-f` for strings, `-F` for typed values, and `-d @file` for a raw
JSON request body.

For Forgejo project boards:

1. Check the server's current API documentation or Swagger schema; do not
   assume GitHub Projects v2 semantics.
2. List the repository or organization projects, then identify the project ID
   and the required board, column, card, or item IDs.
3. Use `tea api` for the exact supported endpoint and HTTP method.
4. Read the project back after each structural mutation.

Forgejo project APIs vary with server version. Discover the live schema instead
of embedding an unverified endpoint in automation.

## Bodies and structured payloads

Draft substantial issue, pull request, comment, and API payloads in a temporary
file. This preserves Markdown and makes the exact external write reviewable.
Use a CLI body-file option when available. If a `tea` command accepts only a
string, pass the reviewed file's contents to `--description`. For raw JSON, use
`tea api -d @payload.json`.

Do not place access tokens, Actions OIDC JWTs, private keys, cookies, or
credential-bearing URLs in arguments, logs, issues, comments, or artifacts.
Use the authenticated credential stores maintained by `gh` and `tea`.

## Report results

Report only confirmed remote state. Include the canonical issue, pull request,
release, Actions run, or project URL and summarize the fields changed. If a
mutation fails or returns an ambiguous response, report it and read the target
back before stating whether remote state changed.
