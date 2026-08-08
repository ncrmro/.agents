# Account setup — GCP console steps

These steps need a browser and the target Google account. A human does
them once per account. For a Workspace account (artera), sign in as the
Workspace user, not a personal account — the project must belong to the
Workspace org.

## 1. Create the GCP project

1. Go to <https://console.cloud.google.com/> signed in as the target
   account (e.g. `you@artera.example`).
2. Create a project, e.g. `agent-workspace-sync`. For Workspace
   accounts, confirm the project's organization is the Workspace org.

## 2. Enable APIs

In **APIs & Services → Library**, enable all three:

- Gmail API
- Google Calendar API
- People API (this is Contacts)

## 3. Consent screen

**APIs & Services → OAuth consent screen**:

- Workspace account: choose **Internal**. This skips Google
  verification and issues non-expiring refresh tokens.
- Personal account (no org): **External** is the only option. Add the
  account itself as a test user. Testing-status refresh tokens expire
  after 7 days; to avoid weekly re-auth, publish the app ("In
  production") — unverified is fine for your own use, the consent
  screen just shows a warning.
- Scopes: you may leave the scope list empty; the CLI requests
  `gmail.readonly`, `calendar.readonly`, `contacts.readonly` at auth
  time.

## 4. OAuth client

**APIs & Services → Credentials → Create credentials → OAuth client
ID** → application type **Desktop app**. Download the JSON.

## 5. Place the secret and authenticate

```sh
mkdir -p ~/.config/google-workspace/artera
cp ~/Downloads/client_secret_*.json ~/.config/google-workspace/artera/client_secret.json
chmod 600 ~/.config/google-workspace/artera/client_secret.json
~/.agents/skills/google-workspace/scripts/gws.py auth artera
```

The auth command opens a browser for consent, then stores
`token.json` next to the secret.

## 6. Escrow the secret

Add `client_secret.json` to `ncrmro/secrets` (SOPS/agenix) so the
client survives machine loss. The refresh token stays local-only;
re-consent on a new machine is cheap.
