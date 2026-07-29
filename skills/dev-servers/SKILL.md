---
name: dev-servers
description: Allocate, record, and resolve local dev-server ports so tooling always talks to this checkout's server. Use before any command that starts a server (devenv up, vite, next dev, npm/bun run dev, rails s, manage.py runserver), before pointing a browser, Playwright, curl, or a test suite at a dev URL, and when introducing the pattern to a repo. Dev servers fall forward to the next free port when theirs is taken, so a hardcoded URL silently hits another worktree's server and per-directory status commands report "nothing running" while several are up.
---

# Dev servers

Ports are a preference, not a reservation. When a dev server's port is taken it
falls forward to the next one — no failure, no warning. Two consequences, and
the second is the expensive one:

- **Duplicates accumulate.** Starting is idempotent only inside one app
  directory; across worktrees every start adds a server, and the old ones keep
  serving stale code for days.
- **Tooling talks to the wrong server.** A hardcoded `localhost:4001` in a test
  config, a browser session, or a curl check hits whichever checkout won that
  port. The suite passes against another branch's code and tells you nothing.

Framework status commands (`astro dev status` and friends) answer neither: they
key on a lock inside the app directory, so a fresh worktree reports nothing
running however many servers are up, and they never see the checkout next door.

## The pattern: allocate, record, consume

Do not let the server pick. Choose the port *before* starting it, write it down,
and have every consumer read the record. Then the URL is knowable before the
server is up, by any tool, without inspecting processes.

The cascade is the conventional dotenv one, **per app** — the same place Vite,
Astro, and Next already load these files from:

- **`<app>/.env`** — committed. The app's preferred port, the project's default.
- **`<app>/.env.local`** — gitignored. What this checkout actually got.

One file per app, not one shared file for the monorepo. That is what the
frameworks expect, and it means each allocator owns its own record: no shared
mutable state, so no locking.

`dev-port` decides the port. It keeps the recorded one while it is still
available, keeps a port this app's own server already holds (so restarts are
idempotent), and reallocates only when something else took it.

```sh
#!/bin/sh
# dev-port <preferred-port> [app-dir]
set -eu
preferred=$1; dir=$(cd "${2:-.}" && pwd -P); envfile="$dir/.env.local"

# Any listener at all, including another user's, whose pid ss will not show.
port_busy() { [ -n "$(ss -lntH "sport = :$1" 2>/dev/null)" ]; }
# Working directory of whoever is listening, or empty if unknown.
port_owner() {
	ss -lptnH "sport = :$1" 2>/dev/null |
		sed -nE 's/.*pid=([0-9]+).*/\1/p' |
		while read -r pid; do readlink "/proc/$pid/cwd" 2>/dev/null && break; done
}
usable() {
	port_busy "$1" || return 0            # free
	[ "$(port_owner "$1")" = "$dir" ]     # or already ours
}

recorded=$(sed -n 's/^DEV_PORT=//p' "$envfile" 2>/dev/null | tail -1)

port=""
for candidate in ${recorded:-} "$preferred"; do
	if usable "$candidate"; then port=$candidate; break; fi
done
if [ -z "$port" ]; then
	port=$preferred
	while ! usable "$port"; do port=$((port + 1)); done
fi

# Only this app writes this file, so an atomic replace is all the coordination
# needed — no lock, and a crash cannot leave a half-written record.
tmp=$(mktemp "$envfile.XXXXXX")
{
	grep -v '^DEV_\(PORT\|URL\)=' "$envfile" 2>/dev/null || :
	printf 'DEV_PORT=%s\nDEV_URL=http://localhost:%s\n' "$port" "$port"
} >"$tmp"
mv "$tmp" "$envfile"

echo "$port"
```

Verified behaviour: preferred port free → takes it; held by another directory →
allocates the next free one and records it; rerun with the recorded port still
free → same port, no drift; recorded port held by this app's own server → kept;
recorded port taken by someone else → reallocated and the record updated; three
apps allocating at once → three distinct ports, no lost keys.

### Wiring it into the process runner

The runner asks for a port, then passes it explicitly:

```nix
processes.web.exec = ''
  port=$(dev-port 4000 "$PWD/apps/web")
  cd apps/web && exec node node_modules/.bin/astro dev --host 0.0.0.0 --port "$port"
'';
```

**Pin the port in the framework, or the record can lie.** Allocation closes the
window but does not eliminate it: if anything grabs the port between the probe
and the bind, a non-strict server falls forward and `.env.local` is then wrong —
worse than having no record. Set the framework's strict-port so it fails loudly
instead: `server.strictPort` in Vite's config (which is how Astro and many
others expose it), `--strict-port` where the CLI has it. A loud failure is
recoverable; a silent lie is not.

### Consuming the record

Everything that needs a base URL reads the record instead of a constant:

```sh
app_url() { sed -n 's/^DEV_URL=//p' "$1/.env.local" 2>/dev/null | tail -1; }

WEB_URL=${WEB_URL:-$(app_url apps/web)}
API_URL=${API_URL:-$(app_url apps/api)}
BASE_URL=$WEB_URL npx playwright test
```

Keep the project's existing environment-variable overrides in front of it, so
CI and staging still win. The committed `.env` supplies the default when nothing
has been allocated yet.

## When you did not start it

For a server this pattern never touched — another repo, a project that has not
adopted it, something started by hand — fall back to asking the OS. A listening
port plus the owning process's working directory identifies a server with no
framework knowledge at all.

`dev-url [dir] [preferred]` — the base URL of whatever serves a directory:

```sh
ss -lptnH 2>/dev/null |
  awk '{ split($4, a, ":"); port = a[length(a)]
         n = split($0, p, "pid=")
         for (i = 2; i <= n; i++) { split(p[i], f, ","); print port, f[1] } }' |
  sort -nu |
  while read -r port pid; do
    [ "$(readlink "/proc/$pid/cwd" 2>/dev/null)" = "$dir" ] || continue
    [ "$port" -ge "${preferred:-0}" ] || continue
    echo "http://localhost:$port"; break
  done
```

Pass the conventional port as `preferred`: a dev server usually holds several
ports from the same directory (Node's inspector on 9229, HMR and IPC on
ephemeral ports), and fall-forward only moves up, so "lowest port at or above
the preference" picks the right one.

`dev-servers` — the same query with no directory filter, to answer "is one
already running?" before starting anything:

```text
PORT   PID      DIRECTORY
4001   154001   …/project.worktrees/feat-a/code/control-plane
4021   3427386  …/project.worktrees/feat-b/code/control-plane
4321   2429879  …/other-repo/code/web
```

**Read the DIRECTORY column, not the port.** Ports are handed out in start
order, so a fall-forward server sitting on another app's conventional port is
normal and routinely misread.

| What you see | Do |
| --- | --- |
| A server whose directory is the one you are working in | Reuse it. |
| A server for your app in a **different** worktree | It serves that code, not yours, and cannot test your change. Do not reuse it; do not silently start a duplicate either — say which directory holds the port and let the user decide. |
| Nothing for your app | Start one, then report the port and pid. |
| Anything you started and no longer need | Stop it. |

`ps -o lstart= -p <pid>` tells you whether a server is abandoned.

## Introducing this to a repo

1. Add the `dev-port` / `dev-url` / `dev-servers` scripts to the environment,
   and `pkgs.iproute2` for `ss`. The scripts need `ss` for one thing: mapping a
   listening port back to its owning process's working directory, which is what
   answers "is this port busy because *my* server already holds it?". Drop that
   check and a re-run allocates a fresh port and starts a second server for the
   same app. Declaring the package is about hermeticity rather than
   availability — `ss` is on essentially every Linux host, but inheriting it
   silently is how it goes missing.
2. Commit `<app>/.env` with each app's preferred port. **Check the ignore rules
   first**: many repos gitignore `.env` outright because it conventionally holds
   secrets. Un-ignore it, or name the committed defaults something else and
   source both.
3. Gitignore `<app>/.env.local` — being an ignored file is what makes it safe to
   rewrite per checkout.
4. Register the devenv MCP in the **project's** `.agents/mcp.json`, never the
   global layer — it exits immediately where there is no `devenv.nix`, so a
   global entry is a failed server in every non-devenv repo:

   ```json
   {
     "mcpServers": {
       "devenv": { "command": "devenv", "args": ["mcp"], "transport": "stdio" }
     }
   }
   ```
4. Change each process `exec` to allocate, and set the framework's strict-port.
5. Point the test runner's base URLs at the record, behind existing overrides.

## devenv notes

`devenv up` runs processes in the foreground, `-d` detaches, `devenv up <name>`
runs one. Under an agent session a self-daemonizing server turns those processes
into *starters*: process-compose shows them Completed while the daemons keep
serving, so stop daemons per app rather than through process-compose. devenv
scripts exist only inside an activated environment — reachable via
`direnv exec .`, `devenv shell --`, or an activated shell.

`devenv mcp` cannot substitute for any of this. It only sees process-compose
processes from `devenv up -d`, so a self-daemonized server is invisible
(`list_processes` returns "No native process manager running" while servers are
up); for a process it does see it knows the *command*, not the port actually
bound; and it is scoped to one project's state directory, so it never sees
another worktree. Use it to control processes you started with `devenv up -d`,
and register it in the project's `.agents/mcp.json` rather than the global
layer: it exits immediately where there is no `devenv.nix`, so a global entry
is a failed server in every non-devenv repo.

## Limits

- Linux: `/proc/<pid>/cwd` and `ss`. The macOS shape is
  `lsof -nP -iTCP -sTCP:LISTEN` plus `lsof -a -p <pid> -d cwd` — not verified
  here.
- Two allocators can still probe the same free port in the same instant — a
  different app in the same repo, or the same app in another worktree. Nothing
  coordinates them, because a port is not reserved until something binds it.
  Strict-port is what makes that survivable: the loser fails to start instead
  of falling forward onto a port its record does not name, and the next run
  sees the port taken and moves on. Without strict-port this race produces a
  record that lies, which is the one outcome worse than no record.
- `dev-url` matches the working directory exactly, so it finds servers that run
  from their app directory. A server started from the repo root serving a
  subdirectory needs the root passed instead.
- Some frameworks additionally record their own port (Astro writes
  `<app>/.astro/dev.json` with pid, port, url and startedAt). Useful for
  staleness when it exists, but most frameworks write nothing, so it is a bonus
  rather than the mechanism.
