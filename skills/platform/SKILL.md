---
name: platform
description: Platform-engineering standards for developer environments and microVMs, Nix-packaged npm applications and containers, and agent configuration. Use when creating or changing devenv configurations, dev-server startup (ports, hostnames, process supervision), microVM configuration, lifecycle, diagnostics, or cleanup, Nix flake or container outputs for npm packages, or the .agents / Outfitter configuration layers of a repository.
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

## Release automation

Version and release repositories with release-please: Conventional Commits on the default branch drive one release PR that bumps the version + CHANGELOG, and merging it tags a GitHub release that a **separate** workflow publishes (npm with provenance, a container, or a git tag). Read [`references/release-please.md`](references/release-please.md) before adding or changing a release-please config or a publish workflow — it covers the org PAT needed because `GITHUB_TOKEN` is blocked from opening PRs, the `node` vs `simple` release types (and pre-1.0 bump behavior), and publishing on `release: published`.

## Agent configuration (.agents and Outfitter)

Repositories keep agent-facing configuration in the `.agents` directory standard (skills, shared conventions), while Outfitter composes shared roles/profiles across repositories from a settings source graph. Read [`references/agents.dotfiles.md`](references/agents.dotfiles.md) for the layout, how Outfitter consumes it today, and the migration direction (Outfitter RFC #165).

For repositories where agents (or humans) should land PRs automatically once CI passes — the merge target for the `subagent-delegation` skill's `pr` land path — read [`references/automerge-merge-queues.md`](references/automerge-merge-queues.md): enabling `gh pr merge --auto`, the required branch-protection/ruleset gate, and when to add a merge queue.

## Operating rules

- Inspect the repository's existing platform conventions before changing them; extend rather than fork.
- Validate configuration changes by running them (`devenv up`, curl the ports, `outfitter validate`) — not by reading alone.
- Content committed to shared catalogs must stay project-agnostic: no consumer names, machine paths, or credentials. Project specifics belong in the consuming repository's own `AGENTS.md` and `.agents/skills/`.
