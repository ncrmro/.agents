# Runbook — set up a Google Workspace account for the CLI

Stand up read-only Gmail/Calendar/Contacts access for one Google
account through `gws.py`. A human does the browser steps once per
account. Verified 2026-08-09 on the `artera` account (jtco.io
Workspace).

Two properties make or break this:

- **Own the app in the right place.** For a Workspace account, the GCP
  project MUST live in that account's Workspace organization, with an
  **Internal** consent screen. Internal skips Google verification,
  shows no "unverified app" warning, and issues durable refresh
  tokens. An External app in "testing" expires refresh tokens after 7
  days — a sync built on it dies weekly.
- **The redirect is localhost on the machine running `gws.py`.** Auth
  works headless: `gws.py auth` prints a consent URL; open it in any
  browser **on the same machine**, because Google redirects to
  `http://localhost:<port>/` where the CLI's local server is waiting.

## 0. Identify the account

The account you consent as owns the mailbox you get. Aliases and
secondary-domain addresses share one mailbox: e.g.
`nicholas@artera.space` is a secondary-domain alias of
`ncrmro@jtco.io`, so you consent as `ncrmro@jtco.io` and read the
artera.space mail. Pick a short slug for the account dir
(`artera`, `ncrmro`).

## 1. Create the GCP project (Workspace org)

Sign in to <https://console.cloud.google.com/> **as the Workspace
user** (not a personal account). The console may demand a passkey
step-up and first-run Terms of Service — both are the human's to
complete.

**New project** → set Organization and Parent resource to the
Workspace org (e.g. `jtco.io`), name it `agent-workspace-sync`,
Create. Confirm the banner reads "…in organization '<your org>'".

## 2. Enable the three APIs

For each, open the library URL for your project and click **Enable**
(wait for "Status: Enabled" — the click can miss during page render,
so verify each):

- `https://console.cloud.google.com/apis/library/gmail.googleapis.com?project=<PROJECT>`
- `https://console.cloud.google.com/apis/library/calendar-json.googleapis.com?project=<PROJECT>`
- `https://console.cloud.google.com/apis/library/people.googleapis.com?project=<PROJECT>` (People API = Contacts)

An API enabled seconds ago can still 403 with `accessNotConfigured` /
`SERVICE_DISABLED` for a minute or two — that means it is enabling,
retry; it does not mean the enable failed.

## 3. Consent screen — Internal

**Google Auth Platform → Get started**:

- App name: e.g. `Agent Workspace Sync`; support email: the Workspace
  user.
- **Audience: Internal.** (For a personal account with no org,
  External is the only option — then publish it "In production" to
  avoid the 7-day token expiry; the unverified warning is harmless for
  your own use.)
- Contact email: the Workspace user. Accept the User Data Policy.

Leave the scope list empty — the CLI requests `gmail.readonly`,
`calendar.readonly`, `contacts.readonly` at auth time.

## 4. Desktop OAuth client

**Clients → Create client** → Application type **Desktop app** →
Create. The dialog shows the Client ID and secret once.

## 5. Place the client secret

`gws.py` reads a Desktop client-secret JSON. If the browser download
did not land on this machine, write it from the dialog values (a
Desktop client secret is non-confidential per OAuth RFC 8252):

```sh
mkdir -p ~/.config/google-workspace/<slug>
cat > ~/.config/google-workspace/<slug>/client_secret.json <<'JSON'
{
  "installed": {
    "client_id": "<CLIENT_ID>.apps.googleusercontent.com",
    "project_id": "<PROJECT>",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "<CLIENT_SECRET>",
    "redirect_uris": ["http://localhost"]
  }
}
JSON
chmod 600 ~/.config/google-workspace/<slug>/client_secret.json
```

## 6. Authenticate (headless)

```sh
~/.agents/skills/google-workspace/scripts/gws.py auth <slug>
```

It prints a consent URL and waits. Open the URL in a browser **on this
machine**, choose the target account, and Allow (an Internal app shows
no unverified warning). The redirect completes the flow and writes
`token.json` (0600) next to the secret.

## 7. Verify

```sh
~/.agents/skills/google-workspace/scripts/gws.py accounts
~/.agents/skills/google-workspace/scripts/gws.py gmail-list <slug> --query 'newer_than:7d' --max 5
~/.agents/skills/google-workspace/scripts/gws.py calendar-events <slug> --days 14
~/.agents/skills/google-workspace/scripts/gws.py contacts-list <slug> --max 5
```

`accounts` should show `authenticated: true`. An empty
`contacts-list` is a valid result, not a failure — many Workspace
accounts have no saved personal contacts.

## 8. Escrow the client secret

Add `client_secret.json` to `ncrmro/secrets` (SOPS/agenix) so the
client survives machine loss. `token.json` stays local-only;
re-consent on a new machine is one `gws.py auth` away.

## Troubleshooting

- `could not locate runnable browser` — old behavior; the CLI now
  prints the URL instead. Update `gws.py` if you still see it.
- `accessNotConfigured` / `SERVICE_DISABLED` — the named API is off
  for the project (step 2), or was just enabled and is still
  propagating; wait and retry.
- `invalid_grant` on refresh — token revoked/expired; re-run `auth`.
  If it recurs weekly, the app is External/testing — move it into the
  Workspace org as Internal (steps 1, 3).
- Consent shows "Google hasn't verified this app" — the app is
  External. Fine for a personal account (click Advanced → proceed);
  for a Workspace account, make it Internal.
