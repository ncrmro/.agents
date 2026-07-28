# Kubernetes deployment authentication with Actions OIDC

This runbook configures the Kubernetes API server to validate GitHub Actions
and Forgejo Actions JWTs directly, avoiding long-lived service-account tokens
and kubeconfigs in either provider. Actions tokens identify CI workloads, not
humans; use a separate interactive-login solution when people also need
OIDC-backed `kubectl`.

Keep provider- and cluster-specific values and policies in the consuming
infrastructure repositories.

## Contents

- [Choose direct validation](#choose-direct-validation)
- [Separate ownership](#separate-ownership)
- [Define the trust contract](#define-the-trust-contract)
- [Inspect prerequisites](#inspect-prerequisites)
- [Configure Kubernetes JWT authentication](#configure-kubernetes-jwt-authentication)
- [Install the configuration on K3s with NixOS](#install-the-configuration-on-k3s-with-nixos)
- [Authorize exact workflow identities](#authorize-exact-workflow-identities)
- [Request and use a token in Actions](#request-and-use-a-token-in-actions)
- [Roll out and verify](#roll-out-and-verify)
- [Revoke, rotate, and roll back](#revoke-rotate-and-roll-back)
- [Forgejo runner and workflow traps](#forgejo-runner-and-workflow-traps)
- [Diagnose failures](#diagnose-failures)
- [Alternatives](#alternatives)
- [Upstream references](#upstream-references)

## Choose direct validation

Prefer Kubernetes' structured `AuthenticationConfiguration` when the API server
can reach each issuer's OIDC discovery and JWKS endpoints. It supports multiple
JWT issuers, audience validation, CEL claim validation, and deterministic claim
mapping without deploying an identity broker.

Use these issuers:

- GitHub Actions: `https://token.actions.githubusercontent.com`
- Forgejo Actions: `https://<forgejo-host>/api/actions`

## Separate ownership

Keep the control-plane trust configuration in the host or cluster-bootstrap
configuration that owns the API server. Keep namespaced authorization in the
cluster configuration:

| Concern | Owner |
| --- | --- |
| Issuer URLs, audiences, claim mapping | API-server host configuration |
| API reachability and TLS certificate | Cluster/network configuration |
| Namespaced Role and RoleBinding | Cluster application configuration |
| OIDC opt-in and token request | Application workflow |
| Repository, branch, environment, and workflow protections | Git provider |

Do not make an application deployment able to rewrite the API server's issuer
trust. Preserve an independent administrator kubeconfig as the break-glass path.

## Define the trust contract

Choose one audience for the cluster, such as `kubernetes-<cluster-id>`. Treat it
as a stable identifier, not as a secret. Require the workflow to request that
exact audience and the API server to accept only that audience.

Constrain each workflow identity with every applicable value:

1. issuer;
2. audience;
3. numeric repository ID when the provider emits it;
4. exact subject, which identifies the branch, tag, pull request, or GitHub
   deployment environment;
5. event name;
6. exact workflow reference;
7. reusable job workflow reference, when GitHub reusable workflows form the
   deployment boundary.

Do not authorize solely by actor, repository owner, repository name, or the
`system:authenticated` group. Do not grant deployment access to pull-request
subjects. Treat `pull_request_target` and equivalent privileged events as
untrusted unless the job never executes or consumes pull-request-controlled
content.

GitHub emits numeric repository identity claims, and newer GitHub subjects can
also include immutable owner and repository IDs. Newer Forgejo subject formats
may encode numeric owner and repository IDs, while older repositories can
retain name-based subjects. Capture a token from each intended workflow before
creating the RoleBinding, then bind only claims or subject components that
token contains. Prefer `repository_id` and `repository_owner_id` over names
when available.

## Inspect prerequisites

Before changing the control plane:

1. Run `kubectl version` and record the server and K3s versions. This runbook
   requires Kubernetes 1.34 or newer, where
   `apiVersion: apiserver.config.k8s.io/v1` `AuthenticationConfiguration` is
   stable.
2. Confirm the API-server host can validate TLS and fetch:
   - `<issuer>/.well-known/openid-configuration`;
   - the `jwks_uri` returned by discovery.
3. Check that no legacy `--oidc-*` API-server flags conflict with the structured
   authentication file.
4. Confirm the issuer does not equal the Kubernetes service-account issuer.
5. Confirm the runner has network and DNS access to the Kubernetes API.

OIDC does not make a private API reachable. The runner still needs access
through the private network, a narrowly scoped VPN, or another approved path.

## Configure Kubernetes JWT authentication

Substitute the Forgejo issuer and cluster audience in this template. Keep
issuer URLs unique. Each group includes the repository ID, subject, event, and
workflow ref so RBAC can bind that workflow identity.

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AuthenticationConfiguration
jwt:
  - issuer:
      url: https://token.actions.githubusercontent.com
      audiences:
        - kubernetes-<cluster-id>
    claimValidationRules:
      - expression: >-
          has(claims.sub) &&
          has(claims.repository_id) &&
          has(claims.event_name) &&
          has(claims.workflow_ref)
        message: required GitHub Actions deployment claims are missing
      - expression: claims.exp - claims.nbf <= 3600
        message: token lifetime must not exceed one hour
    claimMappings:
      username:
        expression: "'oidc:github:' + claims.sub"
      groups:
        expression: >-
          ['oidc:github:repo:' + claims.repository_id +
          ':subject:' + claims.sub +
          ':event:' + claims.event_name +
          ':workflow:' + claims.workflow_ref]
    userValidationRules:
      - expression: "!user.username.startsWith('system:')"
        message: username must not use the reserved system prefix
      - expression: "user.groups.all(group, !group.startsWith('system:'))"
        message: groups must not use the reserved system prefix

  - issuer:
      url: https://<forgejo-host>/api/actions
      audiences:
        - kubernetes-<cluster-id>
    claimValidationRules:
      - expression: >-
          has(claims.sub) &&
          has(claims.repository_id) &&
          has(claims.event_name) &&
          has(claims.workflow_ref)
        message: required Forgejo Actions deployment claims are missing
      - expression: claims.exp - claims.nbf <= 3600
        message: token lifetime must not exceed one hour
    claimMappings:
      username:
        expression: "'oidc:forgejo:' + claims.sub"
      groups:
        expression: >-
          ['oidc:forgejo:repo:' + claims.repository_id +
          ':subject:' + claims.sub +
          ':event:' + claims.event_name +
          ':workflow:' + claims.workflow_ref]
    userValidationRules:
      - expression: "!user.username.startsWith('system:')"
        message: username must not use the reserved system prefix
      - expression: "user.groups.all(group, !group.startsWith('system:'))"
        message: groups must not use the reserved system prefix
```

Inspect a live Forgejo token before selecting its mapping. If it contains
`repository_id`, use the template above. Otherwise, check the Forgejo version
and the repository's Actions identity migration options. If migration is not
yet possible, map `sub`, `event_name`, and `workflow_ref` without
`repository_id`. Document the name-reuse risk and remove this exception after
migration.

For a GitHub reusable deployment workflow, also validate and map the exact
`job_workflow_ref`. Do not assume it exists: capture a token from the actual
reusable-workflow path first.

## Install the configuration on K3s with NixOS

Render the YAML from Nix rather than placing mutable state under `/etc`. The
host module should own both the file and the K3s API-server argument:

```nix
{ pkgs, ... }:
let
  yaml = pkgs.formats.yaml { };
  authenticationConfig = yaml.generate "authentication-config.yaml" {
    apiVersion = "apiserver.config.k8s.io/v1";
    kind = "AuthenticationConfiguration";
    jwt = [
      # Translate the reviewed YAML entries above to Nix attrsets.
    ];
  };
in
{
  environment.etc."rancher/k3s/authentication-config.yaml".source =
    authenticationConfig;

  services.k3s.extraFlags = toString [
    # Preserve the host's existing flags.
    "--kube-apiserver-arg=authentication-config=/etc/rancher/k3s/authentication-config.yaml"
  ];

  systemd.services.k3s.restartTriggers = [ authenticationConfig ];
}
```

Extend the existing `extraFlags`; do not replace unrelated networking, runtime,
or TLS flags. Build the full host before switching. Keep an independent host
login and administrator kubeconfig so an invalid authentication file cannot
lock out the operator.

## Authorize exact workflow identities

Grant only the resource types and verbs the deployment needs, then bind the
group produced by the approved claim mapping:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deploy-workflow
  namespace: <namespace>
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: >-
      oidc:<provider>:repo:<numeric-repository-id>:subject:<exact-sub>:event:<event-name>:workflow:<exact-workflow-ref>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deploy
```

Use separate RoleBindings when GitHub and Forgejo both deploy the application.
Avoid `ClusterRoleBinding` and cluster-admin. If the workflow must touch a
cluster-scoped resource, grant only that resource and verb in a dedicated
ClusterRole and bind the same identity.

## Request and use a token in Actions

Enable OIDC only on the deployment job.

GitHub Actions:

```yaml
jobs:
  deploy:
    permissions:
      contents: read
      id-token: write
```

Forgejo Actions:

```yaml
jobs:
  deploy:
    enable-openid-connect: true
```

Both providers expose `ACTIONS_ID_TOKEN_REQUEST_URL` and
`ACTIONS_ID_TOKEN_REQUEST_TOKEN`. Request the cluster audience and use the
returned JWT as the Kubernetes bearer token:

```bash
set -euo pipefail
set +x

oidc_token="$(
  curl --fail --silent --show-error \
    --header "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
    "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=${KUBE_OIDC_AUDIENCE}" |
    jq --exit-status --raw-output '.value'
)"

kubectl \
  --server="${KUBE_SERVER}" \
  --certificate-authority="${KUBE_CA_FILE}" \
  --token="${oidc_token}" \
  auth can-i get deployments.apps \
  --namespace="${KUBE_NAMESPACE}"

kubectl \
  --server="${KUBE_SERVER}" \
  --certificate-authority="${KUBE_CA_FILE}" \
  --token="${oidc_token}" \
  apply --namespace="${KUBE_NAMESPACE}" --filename=-

unset oidc_token
```

Disable shell tracing around the token request and `kubectl` invocation, and
never expose the token through logs, artifacts, caches, outputs, or a persistent
kubeconfig. The API server URL, audience, and CA certificate are trust
configuration, not private credentials; keep them in reviewed repository
configuration or provider variables. Base64 encoding a CA certificate does not
make it secret.

## Roll out and verify

Use this order to distinguish authentication failures from authorization
failures:

1. Build the host configuration.
2. Keep an administrator session open.
3. Activate the API-server authentication configuration.
4. Check `k3s` status and logs for discovery, JWKS, YAML, and CEL errors.
5. Request a token from the real protected deployment workflow.
6. Before adding RBAC, present the token to the API.
   - `401 Unauthorized` means issuer, signature, audience, expiry, or claim
     validation failed.
   - `403 Forbidden` means authentication succeeded and RBAC correctly denied
     the still-unbound identity.
7. Inspect the authenticated username and groups with a `SelfSubjectReview`
   where supported, or temporarily log audit metadata without logging the JWT.
8. Add the least-privilege Role and exact RoleBinding.
9. Run `kubectl auth can-i` for one allowed and one forbidden operation.
10. Run a harmless server-side dry run, then the real deployment.
11. Verify denial when the token has a disallowed repository, workflow, subject,
    audience, or event.
12. Remove the old provider kubeconfig or service-account token after two
    successful protected-workflow runs with distinct issued tokens and one
    successful negative test.

Verify with a token issued to the real workflow. A fabricated JWT or a payload
decoded without signature verification proves neither the provider's claims
nor the API server's validation.

## Revoke, rotate, and roll back

Revoke access by removing the RoleBinding first. This leaves issuer trust in
place but removes authorization immediately. Then remove obsolete workflow
allowlists or claim mappings from the host configuration.

Do not copy provider signing keys into static configuration. The API server
discovers verification keys through the issuer's OIDC metadata and JWKS.
Monitor issuer reachability and alert on JWT signature or key-refresh failures
in API-server logs.

To change an audience, overlap old and new audiences only for a bounded
migration with a named owner and removal date. Update workflows and
RoleBindings, verify the new path, then remove the old audience.

To roll back a broken control-plane change:

1. use the independent administrator/host session;
2. remove the `authentication-config` API-server argument;
3. restore the last known-good host generation and restart K3s;
4. confirm administrator access;
5. diagnose offline before retrying.

Do not delete existing break-glass credentials as part of the initial rollout.

## Forgejo runner and workflow traps

These failures happen before any token reaches the API server, so the OIDC
diagnosis order below never gets a chance to run. Triage them first (verified
on Forgejo 15):

- **Run fails at creation, zero logs, `created_at == updated_at`:** Forgejo
  rejected the workflow while planning it, and neither the run page, the
  server journal, nor the runner journal records why. The known trigger is a
  **job-level `env:` block containing `${{ }}` expressions** (for example
  `${{ runner.temp }}` or the forge context SHA). Move expression-valued env
  down to the steps that need it; static strings are fine at job level.
  Bisect by stripping the workflow to a single `echo` step and adding pieces
  back — a sibling minimal workflow that runs proves the repo, runner, and
  trigger are healthy.
- **Checkout fails after ~30s of connection retries:** docker-backed runner
  labels (e.g. `ubuntu-latest:docker://…`) execute the job inside a
  container, but the checkout action clones through the *runner's* configured
  instance URL. If the runner registers against a loopback or host-local
  address (`http://127.0.0.1:3001`), that address does not resolve to the
  forge from inside the job container. Options: run deploy jobs on a
  host-backed label (`native:host`), or register the runner with an instance
  URL reachable from job containers. A probe job with no checkout step will
  pass and hide this — include a checkout in any pipeline smoke test.
- **No job-log API:** Forgejo 15's API (`/actions/tasks`, `/actions/runs`)
  exposes statuses but serves no log endpoint, and on-disk actions logs are
  owned by the forge user. Read logs through the web UI (a browser session),
  or infer scheduling from the forge/runner journals (`task N repo is …`
  lines show pickup; their absence during a "failed" run means the run never
  reached a runner).
- **Repository moved or renamed:** every name-based identity component
  (`repository`, `sub`, `workflow_ref`) changes with the owner/name, so
  RBAC group subjects derived from them silently stop matching. Re-derive
  the bound group string after any repo move; prefer immutable numeric IDs
  in claim mappings when the forge emits them.
- **kubectl ≥ 1.35 removed `auth can-i --resource-name`:** a gate script
  written as `kubectl auth can-i patch <resource> --resource-name=<name>`
  errors on every call, and a guard that treats any non-"yes" as denied
  reports a phantom authorization failure. Use the
  `verb resource/name` form (`auth can-i patch configmaps/app-config -n ns`).
  Before blaming RBAC, verify each gate locally with impersonation:
  `kubectl auth can-i <verb> <resource>/<name> --as='<mapped-username>'
  --as-group='<mapped-group>'` — the mapped values come from
  `kubectl auth whoami` run with a live token.
- **The CI-applied manifest must contain only objects the CI identity may
  patch:** `kubectl apply` (and `--dry-run=server`) fails on the first
  unauthorized kind in the file, so one bundled admin-owned object
  (Namespace, Service, CRD) breaks the whole deploy even though the
  identity's own objects are fine. Split manifests by owner: an
  admin-applied infra file for static objects, and a revision-bearing file
  that CI applies. This also keeps the RBAC minimal instead of growing it
  to match a kitchen-sink manifest.
- **Debugging without logs — exfiltrate diagnostics deliberately:** when
  the forge serves no job logs, add a temporary workflow step that pipes
  sanitized output to a listener you control on the private network
  (`{ echo ...; kubectl auth whoami; } 2>&1 | curl --data-binary @- $DIAG`).
  Safe to include: decoded claim payload, whoami output, HTTP status codes.
  Never the token itself. A ~10-line `node:http` server appending request
  bodies to a file is enough on the receiving end. Remove the step once
  green — its removal commit doubles as a repeatability check of the
  pipeline.

## Diagnose failures

Work in this order:

1. **Network:** Can the runner reach the API, and can the API-server host reach
   discovery and JWKS?
2. **TLS:** Do both paths trust the correct CA and match hostnames?
3. **Issuer:** Does token `iss` exactly equal the configured issuer?
4. **Audience:** Was the token explicitly requested for the cluster audience?
5. **Time:** Are `nbf`, `iat`, and `exp` valid, and are clocks synchronized?
6. **Claims:** Does the live token contain the expected repository ID, subject,
   event, and workflow ref with the expected types?
7. **Mapping:** Do CEL expressions evaluate to non-empty, non-`system:` user and
   group strings?
8. **Authorization:** Does the RoleBinding subject exactly match the mapped
   group, including case, event, subject punctuation, workflow `@ref`, and
   immutable IDs?
9. **Scope:** Is the request using the intended namespace and resource API
   group?

Never paste a live JWT into an issue, chat, or shared decoder. If claim
inspection is necessary, decode it only inside the ephemeral job, redact
timestamps and unique run identifiers, and publish only the specific expected
claim values needed to review the binding.

## Alternatives

- **Dex:** use when several human identity providers must appear as one OIDC
  issuer. It adds a service and does not improve direct Actions workload JWTs.
- **Pinniped:** use for polished interactive `kubectl` login, credential
  exchange, and federation. It adds controllers and CRDs.
- **Vault/OpenBao JWT auth:** use when one workload identity must mint
  short-lived Kubernetes, database, and infrastructure credentials. It adds a
  separate security control plane.
- **TokenReview webhook or custom exchanger:** reserve for providers whose
  tokens Kubernetes cannot validate directly or for policy that CEL and RBAC
  cannot express. A custom service increases implementation and availability
  risk.

## Upstream references

- [Kubernetes authentication and structured JWT configuration](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)
- [K3s server flags](https://docs.k3s.io/cli/server)
- [GitHub Actions OpenID Connect reference](https://docs.github.com/en/actions/reference/security/oidc)
- [Forgejo Actions OpenID Connect security](https://forgejo.org/docs/latest/user/actions/security-openid-connect/)
- [Forgejo Actions workflow syntax](https://forgejo.org/docs/latest/user/actions/reference/)
