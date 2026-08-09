---
name: google-workspace
description: Read Gmail messages, Google Calendar events, and Google Contacts from Google Workspace or personal Google accounts through a local OAuth CLI, and sync that data into notes vaults, wikis, and project repos. Use when a task needs email, calendar, or contact data from a Google account (e.g. artera), when adding a new Google account, or when the OAuth token fails.
---

# Google Workspace

Read-only access to Gmail, Calendar, and Contacts through
`scripts/gws.py`. The script runs with `uv` and needs no installation.
All data commands print JSON.

Do not use the claude.ai Gmail/Calendar connectors for sync tasks. They
work only in interactive sessions and do not cover Contacts. Skills and
headless agents MUST use this CLI.

## Accounts

Each account is a directory `~/.config/google-workspace/<account>/` that
holds `client_secret.json` (OAuth desktop client) and `token.json`
(written by `auth`). Account names are short slugs: `artera`, `ncrmro`.

```sh
scripts/gws.py accounts            # list accounts and auth state
scripts/gws.py auth artera         # one-time browser consent (user runs this)
```

The `auth` step opens a browser. The agent MUST NOT run it; hand the
command to the user. Everything else runs headlessly — tokens refresh
automatically.

To add a new account, follow [references/setup.md](references/setup.md):
create a GCP project, enable the three APIs, create a desktop OAuth
client, and place `client_secret.json`. For a Workspace account, the
project MUST live in that Workspace org with an **Internal** consent
screen; an External project in testing status expires refresh tokens
after 7 days.

## Commands

```sh
scripts/gws.py gmail-list artera --query 'newer_than:7d' --max 50
scripts/gws.py gmail-get artera <message-id>          # includes text body
scripts/gws.py gmail-labels artera
scripts/gws.py calendar-list artera
scripts/gws.py calendar-events artera --days 14       # or --time-min/--time-max
scripts/gws.py contacts-list artera --max 500
```

Gmail queries use normal Gmail search syntax (`from:`, `label:`,
`newer_than:7d`, `is:unread`).

## Hosted Google MCP servers

The same account powers Google's hosted Workspace MCP servers
(`gmailmcp.googleapis.com/mcp/v1`, `calendarmcp.googleapis.com/mcp/v1`,
`people.googleapis.com/mcp/v1`). Requirements: the project's per-product
MCP APIs enabled and the project registered in the Google Workspace
Developer Preview Program (see the setup runbook). The layered
`~/.agents/mcp.json` entries authenticate with a header that expands
`${GOOGLE_WORKSPACE_TOKEN}`; mint the value at launch:

```sh
GOOGLE_WORKSPACE_TOKEN=$(scripts/gws.py token artera) claude ...
```

Access tokens live about one hour; long sessions must re-launch or
re-auth. `scripts/gws.py token <account>` always refreshes when needed.

## Sync conventions

When syncing into a vault or project wiki:

- Land synthesized output in the project's wiki area (for artera:
  `wiki/` in the repo, or `wiki/projects/artera/` in the notes vault),
  not raw API dumps.
- Store raw evidence worth keeping as a source package per the `wiki`
  skill; do not commit full mailbox dumps.
- Calendar syncs SHOULD be windowed (`--days`, `--time-min`) and
  idempotent: rewrite the generated file each run instead of appending.
- Never commit `client_secret.json` or `token.json` to any repo. The
  canonical encrypted copy of `client_secret.json` lives in
  `ncrmro/secrets`.

## Troubleshooting

- `no token for account` — run `scripts/gws.py auth <account>` (user).
- `invalid_grant` on refresh — token revoked or expired; re-run `auth`.
  If this repeats weekly on a Workspace account, the OAuth project is
  External/testing — move it inside the Workspace org (see setup doc).
- `accessNotConfigured` / 403 — the API (Gmail, Calendar, or People) is
  not enabled in the GCP project.
- Scope errors after editing SCOPES in the script — delete `token.json`
  and re-auth; stored tokens keep their original scopes.
