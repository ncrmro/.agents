# Stalwart setup and operations on Keystone/NixOS

Use this reference when enabling, changing, upgrading, exposing, or diagnosing a
Stalwart server managed by Keystone and NixOS. Keep fleet-specific hostnames,
domains, certificate names, addresses, and secret paths in the consuming
configuration.

## Contents

- [Source-of-truth order](#source-of-truth-order)
- [Declarative topology](#declarative-topology)
- [Secrets and fallback administration](#secrets-and-fallback-administration)
- [Compatibility, storage, and upgrades](#compatibility-storage-and-upgrades)
- [TLS and reverse proxy](#tls-and-reverse-proxy)
- [Deployment and verification](#deployment-and-verification)
- [Diagnostic order](#diagnostic-order)

## Source-of-truth order

Inspect the live repositories before changing mail infrastructure:

1. The evaluated consumer host configuration is the deployment contract.
2. Keystone's `modules/os/mail.nix` owns reusable service defaults.
3. Consumer host overrides own certificates, reverse proxying, secret
   declarations, listener exposure, and compatibility pins.
4. Convention and operations documents explain intent but can lead or lag the
   module. Resolve disagreements against the evaluated NixOS configuration and
   the running service.

Do not copy the Keystone module into the consumer. Add reusable behavior
upstream and keep deployment-specific values in host configuration.

## Declarative topology

Declare the fleet domain and the one host that runs mail:

```nix
keystone.domain = "example.com";
keystone.services.mail.host = "mail-host";
```

`keystone.os.mail` auto-enables Stalwart only where
`networking.hostName == keystone.services.mail.host`. Host-local policy can
extend it:

```nix
keystone.os.mail.allowedIps = [
  "100.64.0.0/10"
  "fd7a:115c:a1e0::/48"
];
```

Prefer this option to hand-writing Stalwart's `allowed-ip` value. Stalwart's
configuration grammar has set/table semantics that do not always map to a
normal TOML array; the Keystone module performs the Nix-to-Stalwart translation.

Keystone's defaults provide:

- SMTP on 25, submission on 587, implicit-TLS submission on 465, and IMAPS on
  993;
- a local HTTP/JMAP/admin listener on 8082;
- RocksDB data and blob stores under `/var/lib/stalwart-mail`;
- the internal directory for authentication;
- local mail routing, firewall openings for mail protocols, and DAV sharing
  support.

Keep the admin/JMAP listener on loopback unless a concrete same-network
consumer requires otherwise. Publish it through an authenticated or
network-restricted TLS reverse proxy; do not expose the raw management listener
to the public Internet.

## Secrets and fallback administration

Declare the fallback-admin secret through the consumer's encrypted-secret
system, make the decrypted file readable by the Stalwart service account, and
reference it with Stalwart's file macro:

```nix
age.secrets.stalwart-admin-password = {
  file = "${inputs.secrets}/secrets/stalwart-admin-password.age";
  owner = "stalwart-mail";
  group = "stalwart-mail";
  mode = "0400";
};

services.stalwart-mail.settings.authentication.fallback-admin = {
  user = "admin";
  secret = "%{file:/run/agenix/stalwart-admin-password}%";
};
```

Never commit or print the decrypted value. Ensure the mail host is an encrypted
secret recipient.

Fallback-admin secret formats are version-sensitive, and older deployment prose
may disagree about plaintext versus password hashes. Keystone's agent
provisioner reads the decrypted file verbatim and uses its contents as the
local admin API credential. Before changing its format:

1. inspect the effective `services.stalwart-mail` package and `stateVersion`;
2. verify the current file authenticates to `GET /api/principal`;
3. test the replacement against the same version;
4. deploy and re-run every provisioning unit that depends on it.

Do not opportunistically convert the secret because a comment recommends a
different format.

## Compatibility, storage, and upgrades

Set `services.stalwart-mail.stateVersion` explicitly on an existing deployment.
Nixpkgs module and Stalwart upgrades can change the service identity, state
layout, or migration path. A lock-file update must not silently move or orphan
the mail store.

Before changing the package or state version:

1. read the upstream upgrade notes for every crossed version;
2. snapshot or back up the data and blob stores;
3. build the complete host configuration;
4. inspect the generated unit, user, paths, and Stalwart configuration;
5. perform the migration in a maintenance window;
6. verify principals, mail protocols, queues, and DAV before removing the
   snapshot.

Never delete the Stalwart data directory as an authentication-reset procedure.
It deletes accounts and mail, not merely the fallback administrator.

## TLS and reverse proxy

Configure the certificate in a consumer host override:

```nix
services.stalwart-mail.settings.certificate.default = {
  cert = "%{file:/path/to/fullchain.pem}%";
  private-key = "%{file:/path/to/key.pem}%";
  default = true;
};
```

Grant the Stalwart service account only the group/file access needed to read the
certificate. Add `stalwart.service` to the certificate renewal reload or restart
list so renewed material is loaded.

Proxy the HTTP/JMAP listener with WebSocket support when the selected Stalwart
version needs it. Apply the network allowlist at the proxy and retain the
listener's own narrow bind where possible.

## Deployment and verification

Build before switching. In a Keystone consumer, prefer its targeted Keystone
development wrapper while iterating; otherwise update only the intended flake
input and rebuild the mail host.

After activation:

```bash
systemctl status stalwart --no-pager
journalctl -u stalwart --since "10 min ago" --no-pager
systemctl list-units --failed
ss -tln | grep -E ':(25|465|587|993|8082)\b'
```

Verify the local management API without logging the password:

```bash
read -rsp "Stalwart admin password: " STALWART_ADMIN_PASSWORD
echo
curl --fail --silent --show-error \
  --user "admin:${STALWART_ADMIN_PASSWORD}" \
  http://127.0.0.1:8082/api/principal >/dev/null
unset STALWART_ADMIN_PASSWORD
```

Then verify through the TLS proxy and test IMAP and submission with a
non-administrator account. A healthy HTTP endpoint alone does not prove mail
authentication, delivery, or certificate access.

## Diagnostic order

When clients fail:

1. Confirm `stalwart.service` is active; the NixOS unit is not named
   `stalwart-mail.service`.
2. Inspect recent logs for parse errors, unreadable files,
   `security.ip-blocked`, and `security.unauthorized`.
3. Check the effective listener binds and firewall, then the reverse proxy.
4. Verify certificate readability and renewal reload wiring.
5. Test the local API before testing the proxy.
6. Test account name authentication, roles, and protocols separately.
7. Inspect failed `provision-agent-mail-*` units when declarative agent accounts
   are enabled.

For a blocked trusted address, correct the declarative allowlist and clear the
existing runtime block through the admin surface. Do not disable blocking
globally to hide an incorrect network policy.
