# Stalwart account lifecycle

Use this reference for domains and individual principals on a Stalwart server
managed by Keystone. Perform admin API operations on the mail host over its
loopback listener unless the deployment provides an equivalently protected
management path.

## Contents

- [Choose the ownership model first](#choose-the-ownership-model-first)
- [Admin API conventions](#admin-api-conventions)
- [Domains](#domains)
- [Create an individual account](#create-an-individual-account)
- [Maintain an account](#maintain-an-account)
- [Publish credentials directly to Kubernetes](#publish-credentials-directly-to-kubernetes)
- [DAV initialization](#dav-initialization)
- [Validate an account](#validate-an-account)
- [Delete or retire an account](#delete-or-retire-an-account)

## Choose the ownership model first

Use one account owner for the entire lifecycle:

- **Keystone agent account:** declare
  `keystone.os.agents.<name>.mail.provision = true`, provision its encrypted
  secret with `agentctl <name> provision`, and let the mail-host systemd unit
  create the principal and enforce its role.
- **Human or application account:** manage the principal explicitly through
  Stalwart's admin API and manage its client password through the consumer's
  encrypted-secret declarations.

Do not manually create an account that is intended to be declarative without
also completing its Keystone declaration and secret wiring.

Keystone agent provisioning derives:

- principal name: `agent-<name>`;
- default address: `agent-<name>@<keystone.domain>`, unless `mail.address`
  overrides it;
- provisioning unit: `provision-agent-mail-<name>.service`;
- password secret: `agent-<name>-mail-password`.

The password secret must be decryptable by both the agent host, for its client,
and the mail server host, for principal provisioning. `agentctl provision`
constructs both recipients when `keystone.services.mail.host` and the agent
`host` are declared.

## Admin API conventions

Use the Stalwart account **name** as the login. An email address is an address
attribute, not necessarily the authentication name. Missing the `user` role can
allow authentication while denying IMAP, SMTP, JMAP, and DAV operations with
`security.unauthorized`.

Set reusable shell values without committing them:

```bash
STALWART_API=http://127.0.0.1:8082/api
read -rsp "Stalwart admin password: " STALWART_ADMIN_PASSWORD
echo
```

Always use `curl --fail --silent --show-error` for mutations so HTTP errors fail
the operation. Build JSON with `jq`, not string interpolation. HTTP success is
not enough: some Stalwart versions return semantic failures such as
`{"error":"notFound"}` with HTTP 200. Capture every API response and also fail
when its top-level `error` field is non-null.

Principal GET responses can wrap the principal under `data`. Normalize with
`.data // .` before reading fields, but inspect a top-level `error` first.

## Domains

Ensure the mail domain exists before assigning addresses from it:

```bash
curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  "${STALWART_API}/principal" \
  --header "Content-Type: application/json" \
  --data "$(jq -n --arg domain "example.com" \
    '{type: "domain", name: $domain}')"
```

List principals and inspect one by account name:

```bash
curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  "${STALWART_API}/principal" | jq

curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  "${STALWART_API}/principal/example-user" | jq
```

Treat creation as idempotent: GET the exact principal first and create only
when its response means not-found. Depending on the Stalwart version, that can
be either HTTP 404 or HTTP 200 with `error = "notFound"` in the JSON body.
Distinguish both from authentication and server errors.

## Create an individual account

Generate a password without a leading `$`; Stalwart can interpret
`$`-prefixed values as encoded password hashes:

```bash
ACCOUNT_NAME=example-user
ACCOUNT_ADDRESS=example-user@example.com
ACCOUNT_PASSWORD="$(openssl rand -base64 24)"

payload="$(jq -n \
  --arg name "$ACCOUNT_NAME" \
  --arg password "$ACCOUNT_PASSWORD" \
  --arg address "$ACCOUNT_ADDRESS" \
  '{type: "individual", name: $name, secrets: [$password], emails: [$address]}')"

create_response="$(curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  "${STALWART_API}/principal" \
  --header "Content-Type: application/json" \
  --data "$payload")"

jq --exit-status '.error == null' <<<"$create_response" >/dev/null
```

Immediately grant the normal user role:

```bash
role_response="$(curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  --request PATCH \
  "${STALWART_API}/principal/${ACCOUNT_NAME}" \
  --header "Content-Type: application/json" \
  --data '[{"action":"set","field":"roles","value":["user"]}]')"

jq --exit-status '.error == null' <<<"$role_response" >/dev/null
```

Store the exact account password in the encrypted client secret, clear it from
the shell, and avoid command tracing:

```bash
unset payload ACCOUNT_PASSWORD
```

## Maintain an account

Use PATCH `set` operations for addresses, roles, and passwords:

```json
[
  {"action":"set","field":"emails","value":["new-address@example.com"]},
  {"action":"set","field":"roles","value":["user"]}
]
```

Changing an encrypted password file alone does not rotate an existing Stalwart
principal. Keystone's current mail provisioner:

1. creates the account only when it is missing;
2. enforces `roles = ["user"]` on every run;
3. does not PATCH `secrets` for an account that already exists.

Inspect its exact existence check before relying on it with a new Stalwart
version. A check based only on HTTP 200 versus 404 misclassifies the
HTTP-200-plus-`notFound` response and skips account creation. PATCH responses
also require JSON-level error validation.

Rotate a password as one coordinated operation:

1. generate the replacement without logging it;
2. update the encrypted client secret and preserve both required recipients;
3. PATCH the principal's `secrets` field with that exact value;
4. deploy the secret to every client host;
5. restart or retry affected clients and verify authentication;
6. clear temporary plaintext material.

Password PATCH shape:

```bash
password_patch="$(jq -n --arg password "$NEW_ACCOUNT_PASSWORD" \
  '[{"action":"set","field":"secrets","value":[$password]}]')"

password_response="$(curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  --request PATCH \
  "${STALWART_API}/principal/${ACCOUNT_NAME}" \
  --header "Content-Type: application/json" \
  --data "$password_patch")"

jq --exit-status '.error == null' <<<"$password_response" >/dev/null
```

Re-run declarative provisioning after correcting roles or account drift:

```bash
systemctl restart "provision-agent-mail-<name>.service"
journalctl -u "provision-agent-mail-<name>.service" --no-pager
```

## Publish credentials directly to Kubernetes

A live-only Kubernetes Secret does not require SOPS or another committed
manifest. Generate it from a protected temporary environment file so the
password does not appear in shell history or a `kubectl` argument:

```bash
umask 077
secret_work_dir="$(mktemp -d)"
secret_env="${secret_work_dir}/jmap.env"
secret_manifest="${secret_work_dir}/secret.json"

printf '%s\n' \
  'XIN_BASE_URL=https://mail.example.com' \
  'XIN_BASIC_USER=example-user' \
  "XIN_BASIC_PASS=${ACCOUNT_PASSWORD}" \
  >"$secret_env"

kubectl --namespace <namespace> create secret generic <secret-name> \
  --from-env-file="$secret_env" \
  --dry-run=client \
  --output=json >"$secret_manifest"

kubectl apply --server-side \
  --field-manager=stalwart-account-bootstrap \
  --filename="$secret_manifest"
```

Verify metadata and key names without decoding values:

```bash
kubectl --namespace <namespace> get secret <secret-name> \
  --output='go-template={{range $key, $_ := .data}}{{$key}}{{"\n"}}{{end}}'
```

Remove the protected temporary directory immediately after the Secret and
account login are verified. A direct Secret is cluster state, not durable
declarative recovery material; record the rotation procedure and ensure the
account can be re-provisioned if disaster recovery requires it.

When rotating, PATCH the Stalwart principal and update the Kubernetes Secret
from the same in-memory password during one maintenance operation. Replacing
only one side guarantees an authentication outage.

## DAV initialization

CalDAV and CardDAV requests authenticate as the account owner, not fallback
admin. Use `PROPFIND`, `MKCALENDAR`, `MKCOL`, and `ACL`; GET returning 403 does
not prove DAV is broken.

The current Keystone module creates the principal and role, accesses the
account's CalDAV home to trigger default-calendar creation, and applies
configured human-user ACLs to that default calendar. Keystone convention
documents may describe additional personal or team collections ahead of their
implementation. Verify the evaluated module and the collections returned by
`PROPFIND` before relying on them.

Basic DAV check:

```bash
curl --fail --silent --show-error \
  --user "${ACCOUNT_NAME}:${ACCOUNT_PASSWORD}" \
  --request PROPFIND \
  --header "Depth: 1" \
  --header "Content-Type: application/xml" \
  --data '<?xml version="1.0"?><propfind xmlns="DAV:"><prop><resourcetype/></prop></propfind>' \
  "http://127.0.0.1:8082/dav/cal/${ACCOUNT_NAME}/"
```

HTTP 207 is the normal successful WebDAV multi-status response.

## Validate an account

Validate each layer rather than stopping at principal creation:

1. `GET /api/principal/<account-name>` returns the expected name, address, and
   `user` role.
2. IMAPS login succeeds using the account name, not the email address.
3. SMTP submission authenticates and queues a message.
4. The recipient can see the message.
5. JMAP discovery/session succeeds when used by the client.
6. DAV `PROPFIND` returns the expected principal and collections.
7. Agent clients read the same encrypted password that the server principal
   stores.

Expect `/.well-known/jmap` to redirect to the session resource; follow the
redirect when probing it. Use the principal account name as Basic Auth login
unless the deployed server has explicitly verified email-address login.

Unset the admin credential after use:

```bash
unset STALWART_ADMIN_PASSWORD
```

## Delete or retire an account

Deletion removes the principal and can make mailbox data inaccessible. Confirm
retention or migration requirements first.

For a declarative agent:

1. disable `mail.provision` or remove the agent declaration;
2. deploy that change so the provisioning unit no longer owns the account;
3. archive or migrate required mail and DAV data;
4. delete the principal through the API;
5. remove client secret declarations and encrypted files only after no host
   consumes them;
6. remove obsolete secret recipients and rekey.

Delete only the resolved principal:

```bash
curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  --request DELETE \
  "${STALWART_API}/principal/${ACCOUNT_NAME}"
```

Do not delete the Stalwart store to remove one account or reset one password.
