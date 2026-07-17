# Dev servers under devenv v2: 0.0.0.0 + automatic port allocation

The standard for running a repository's dev servers, using devenv (v2.x) as the process runner. Goal: any number of checkouts, worktrees, agents, and humans can start servers concurrently without port fights, and every server is reachable through any hostname (localhost, LAN IP, tunnel, reverse proxy).

## The standard

1. **devenv is the entry point.** Servers are devenv `processes`; `devenv up` starts them all, `devenv up <name>` starts one, `-d` detaches. The toolchain (node, etc.) comes from devenv `packages`, so the processes run identically for every contributor.
2. **Flags go to the server binary directly.** The process `exec` invokes the framework's binary (e.g. `node_modules/.bin/astro`) with explicit flags. Do not route through npm/bun scripts — indirection hides the flags and splits the source of truth.
3. **Bind all interfaces:** pass `--host 0.0.0.0` (or the tool's equivalent). Localhost-only binds break LAN devices, containers, and tunnels.
4. **Accept any hostname.** Dev servers that filter the `Host` header (Vite's `allowedHosts`) must be configured to allow all hosts, otherwise proxied/tunneled hostnames get 403s.
5. **Prefer, never pin, ports.** Give each app a stable conventional port (predictable URLs, stable auth origin allowlists) but rely on the server's non-strict port behavior to fall forward to the next open port when it's taken. Never set strict-port modes for dev.

## devenv v2 shape

```nix
# devenv.nix
{
  packages = [ pkgs.nodejs ];

  processes = {
    web.exec = "cd apps/web && node node_modules/.bin/astro dev --host 0.0.0.0 --port 4000";
    api.exec = "cd apps/api && node node_modules/.bin/astro dev --host 0.0.0.0 --port 4001";
  };
}
```

- `devenv up` runs the processes under process-compose in the devenv environment (so `node` etc. resolve without a global install).
- Process `exec` starts from the project root; `cd` into the app first.
- Machine-level environment fixes belong in devenv `env` (example: NixOS lacks a default CA bundle path, so `env.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";` fixes TLS inside workerd-style dev runtimes).

## Worked example: Astro (verified on astro 7.0.9)

- `astro dev --host 0.0.0.0 --port 4000` binds all interfaces and treats the port as a preference: with 4001 and 4002 busy, `--port 4001` starts the server on 4003 ("auto find open port" needs no extra flags).
- **Hostname allowlist is config, not flag.** `--allowed-hosts` only accepts a comma-separated list (`flags.allowedHosts.split(",")`); the allow-everything boolean is not expressible on the CLI. Set it in `astro.config.mjs`:

  ```js
  vite: {
    server: { allowedHosts: true },
    preview: { allowedHosts: true },
  },
  ```

- **Agents get self-daemonizing servers.** This astro detects agent sessions (`isRunByAgent()`) and backgrounds `astro dev` automatically (same as `--background`), printing the chosen port and exiting 0; the server is then managed with `astro dev stop | status | logs` in the app directory. Consequences:
  - In a human terminal, `devenv up` supervises the servers foreground (Ctrl-C stops them).
  - In an agent session, the devenv processes act as *starters*: process-compose shows them Completed while the daemons keep serving. Stop daemons per app, not via process-compose.
  - The daemon manager is a per-app singleton: a second `astro dev` in the same app reports the running server instead of starting another.

## Multiple agents sharing servers

Self-daemonizing dev servers make sharing the default within one checkout: the daemon is a per-app singleton (astro keys it on the app's `.astro/dev.json` lock), so the first `devenv up` or `astro dev` starts it and every later invocation — from any agent or terminal — attaches and reports the running URL instead of spawning another. A repeated `devenv up -d` is a harmless no-op: each process finds its daemon and exits 0.

Etiquette for concurrent agents:

- **Reuse before starting.** Starting is idempotent; run the starter and read the reported URL.
- **Discover, don't assume, ports.** `astro dev status` returns the URL, pid, and uptime; a busy preferred port falls forward, so hardcoded ports go stale.
- **Never stop a server you didn't start.** `astro dev stop` kills it for every agent in the checkout. Prefer `astro dev logs --follow`; hot reload makes restarts rarely necessary.
- **Worktrees don't share, by design.** Each worktree serves its own code with its own daemons on fall-forward ports; keep origin-checked flows (sign-in) on the checkout that owns the canonical ports.
- Cold-start races are benign: the lock resolves them; worst case a duplicate lands on the next port.

## Sharp edges

- **Origin allowlists assume the preferred ports.** Auth layers with trusted-origin lists (CORS, better-auth `trustedOrigins`) typically enumerate the conventional ports. A server that fell forward to another port still serves pages, but origin-checked flows (sign-in) fail there. Keep the preferred ports free for the primary checkout; treat fall-forward instances as read-mostly.
- **Port fall-forward is first-come:** which checkout gets 4000 depends on start order. If a specific instance must own the port, stop the other instance rather than pinning strict ports.
- **Don't background-manage twice.** If a framework daemonizes itself, do not also wrap it in tmux/nohup/systemd in dev; you'll strand servers no tool knows about.
