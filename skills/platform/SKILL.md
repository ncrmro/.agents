---
name: platform
description: Platform-engineering standards for devenv, microVMs, Nix packaging and user-profile overrides, npm containers, Stalwart on Keystone/NixOS, Kubernetes workload OIDC, and .agents/Outfitter configuration. Use when changing these platform surfaces, including GitHub or Forgejo Actions authentication to Kubernetes.
---

# Platform

Standards for the platform surfaces repositories share: the **developer environment** (devenv-managed toolchains, dev servers, and microVMs), **Nix-packaged npm applications and containers**, and the **agent configuration layers** (the `.agents` directory standard and Outfitter).

## Dev environments and servers

devenv (v2) is the default way to provide a repository's toolchain and to start its dev servers: `devenv shell` for the toolchain, `devenv up` for the servers. Servers are declared as devenv `processes` whose commands invoke the server binaries **directly** with explicit flags — no package-script indirection — so `devenv.nix` is the single source of truth for how a server runs.

The dev-server standard, in one line: **bind `0.0.0.0`, accept any hostname, prefer a conventional port but never pin it strictly — auto-find the next open port when it's taken.** This keeps parallel checkouts, worktrees, agents, tunnels, and LAN/proxy access all working without coordination.

Read [`references/devenv.md`](references/devenv.md) before writing or changing a devenv config — it specifies the standard precisely, shows a worked Astro example, and lists the sharp edges (CLI flag gaps, agent self-daemonizing servers, origin-allowlist interactions).

## MicroVM development environments

Manage development microVMs through devenv processes and tasks. Keep each
checkout self-contained so parallel worktrees do not share disks, sockets, or
fixed host ports.

- Store mutable VM state under
  `${config.devenv.root}/.devenv/state/<vm-name>` and ensure `.devenv` is
  ignored. Keep disks, control sockets, forwarded-service state, caches, and
  generated credentials there rather than in a global user directory.
- Provide explicit lifecycle tasks. `up` may create or reuse state; `down` must
  request graceful guest shutdown and preserve reusable state. Any task that
  deletes disks, caches, fixtures, credentials, or evidence must include
  `reset` or `destroy` in its name and require an exact confirmation value.
- Allocate forwarded host ports dynamically through devenv. Derive guest
  configuration and generated connection files from the allocated ports so
  concurrent checkouts remain independent.
- Put a QMP or equivalent control socket in the VM state directory and use it
  for normal shutdown. If the control path is stale or unreachable, resolve the
  exact hypervisor PID from its full command line, disk path, and forwarded
  ports before sending `SIGTERM`; never kill hypervisors by a broad pattern.
- Diagnose CPU at both layers. Sample current host usage (`top` or `pidstat`)
  because `ps %CPU` is a lifetime average, enumerate hypervisor threads, then
  compare guest or orchestrator metrics. Quiet guest workloads with hot QEMU
  threads indicate virtualization or I/O overhead rather than an application
  pod. A VM whose command line points at a deleted worktree is an orphan; its
  deleted-but-open disk space is released only after that hypervisor exits.
- After shutdown, verify that no matching hypervisor remains and that its
  forwarded ports are no longer listening. Preserve state unless destructive
  cleanup was explicitly requested.

## Nix-packaged npm applications and containers

Use `buildNpmPackage` with `importNpmLock` by default so the committed npm lockfile supplies dependency integrity and release automation does not need to maintain a separate Nix dependency hash. Read [`references/npm-nix.md`](references/npm-nix.md) before adding or changing an npm package flake output or building that package into a Nix container image.

## Fast Nix user-profile overrides

For fast-moving user CLI packages that need to update without rebuilding Home
Manager or NixOS, keep the declarative package as the reproducible baseline and
shadow it with an isolated `nix profile`. Read
[`references/nix-user-profiles.md`](references/nix-user-profiles.md) before
creating the profile or its update script. It covers PATH precedence, unlocked
flake references, safe links, update/rollback behavior, shell command-cache
refresh, verification, and eventual promotion back to the declarative layer.

## Release automation

Version and release repositories with release-please: Conventional Commits on the default branch drive one release PR that bumps the version + CHANGELOG, and merging it tags a GitHub release that a **separate** workflow publishes (npm with provenance, a container, or a git tag). Read [`references/release-please.md`](references/release-please.md) before adding or changing a release-please config or a publish workflow — it covers the org PAT needed because `GITHUB_TOKEN` is blocked from opening PRs, the `node` vs `simple` release types (and pre-1.0 bump behavior), and publishing on `release: published`.

## Cloudflare Workers site CI

For multi-site Astro-on-Workers CI — mock version previews, Playwright smoke,
gated production — read
[`references/cloudflare-workers-site-ci.md`](references/cloudflare-workers-site-ci.md)
before changing a site deploy/preview workflow or a Worker's auth config. It
covers the one-reusable-`workflow_call` consolidation (PR + main run the same
build→preview→smoke path via explicit input flags), the reusable-workflow
`startup_failure` traps (permissions can't escalate; test only via merge), why
Durable Objects block version-preview URLs (and the delete-class migration to
remove one), the `--var` overrides a mock preview needs to not 500
(`ARTERA_DATA_MODE:mock`, `AUTH_STORAGE_MODE:memory`, empty `AUTH_COOKIE_DOMAIN`,
a throwaway `BETTER_AUTH_SECRET`), and the load-bearing rule that **smoke tests
previews, not production** — provision production `wrangler secret`s separately
(missing ones 500 every version, so rollback won't fix them) and curl the live
origins after deploy.

## Stalwart mail infrastructure

For a Stalwart server managed through Keystone/NixOS, read [`references/stalwart-setup.md`](references/stalwart-setup.md) before enabling, upgrading, exposing, or diagnosing the service. It covers the Keystone service registry, NixOS module and host-override boundary, state-version and storage safety, TLS, listeners, secrets, deployment, and verification.

Read [`references/stalwart-accounts.md`](references/stalwart-accounts.md) before creating, changing, rotating, validating, or deleting Stalwart domains and accounts. It separates Keystone's declarative agent provisioning from direct principal API operations and documents the role, login-name, secret-recipient, DAV, and password-rotation traps.

## Kubernetes workload OIDC

For Kubernetes deployments that use GitHub or Forgejo Actions OIDC instead of a
stored kubeconfig, read
[`references/kubernetes-actions-oidc.md`](references/kubernetes-actions-oidc.md)
before changing API-server authentication, workflow token requests, or RBAC. It
covers the host/cluster ownership split, K3s/NixOS configuration, verification,
and recovery.

## Agent configuration (.agents and Outfitter)

Repositories keep agent-facing configuration in the `.agents` directory standard (skills, agents, shared conventions, settings). Pi loads skills natively from `~/.agents/skills/` and project `.agents/skills/`; Outfitter treats `.agents/` as its authored configuration protocol, resolving workspace, global, and remote catalog layers before projecting them into harness-specific runtime config. Read [`references/agents.dotfiles.md`](references/agents.dotfiles.md) before changing `.agents`, Outfitter, agent catalog configuration, or Pi extension loadouts/local overrides.

For repositories where agents (or humans) should land PRs automatically once CI passes — the merge target for the `subagent-delegation` skill's `pr` land path — read [`references/automerge-merge-queues.md`](references/automerge-merge-queues.md): enabling `gh pr merge --auto`, the required branch-protection/ruleset gate, and when to add a merge queue.

## Operating rules

- Inspect the repository's existing platform conventions before changing them; extend rather than fork.
- Validate configuration changes by running them (`devenv up`, curl the ports, `outfitter validate`) — not by reading alone.
- Content committed to shared catalogs must stay project-agnostic: no consumer names, machine paths, or credentials. Project specifics belong in the consuming repository's own `AGENTS.md` and `.agents/skills/`.
