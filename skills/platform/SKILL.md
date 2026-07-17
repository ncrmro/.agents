---
name: platform
description: Platform-engineering standards for developer environments and agent configuration. Use when creating or changing devenv configurations, dev-server startup (ports, hostnames, process supervision), or the .agents / Outfitter configuration layers of a repository.
---

# Platform

Standards for the two platform surfaces every repository shares: the **developer environment** (devenv-managed toolchains and dev servers) and the **agent configuration layers** (the `.agents` directory standard and Outfitter).

## Dev environments and servers

devenv (v2) is the default way to provide a repository's toolchain and to start its dev servers: `devenv shell` for the toolchain, `devenv up` for the servers. Servers are declared as devenv `processes` whose commands invoke the server binaries **directly** with explicit flags — no package-script indirection — so `devenv.nix` is the single source of truth for how a server runs.

The dev-server standard, in one line: **bind `0.0.0.0`, accept any hostname, prefer a conventional port but never pin it strictly — auto-find the next open port when it's taken.** This keeps parallel checkouts, worktrees, agents, tunnels, and LAN/proxy access all working without coordination.

Read [`references/devenv.md`](references/devenv.md) before writing or changing a devenv config — it specifies the standard precisely, shows a worked Astro example, and lists the sharp edges (CLI flag gaps, agent self-daemonizing servers, origin-allowlist interactions).

## Agent configuration (.agents and Outfitter)

Repositories keep agent-facing configuration in the `.agents` directory standard (skills, shared conventions), while Outfitter composes shared roles/profiles across repositories from a settings source graph. Read [`references/agents.dotfiles.md`](references/agents.dotfiles.md) for the layout, how Outfitter consumes it today, and the migration direction (Outfitter RFC #165).

## Operating rules

- Inspect the repository's existing platform conventions before changing them; extend rather than fork.
- Validate configuration changes by running them (`devenv up`, curl the ports, `outfitter profile lint --strict`) — not by reading alone.
- Content committed to shared catalogs must stay project-agnostic: no consumer names, machine paths, or credentials. Project specifics belong in the consuming repository's own `AGENTS.md` and `.agents/skills/`.
