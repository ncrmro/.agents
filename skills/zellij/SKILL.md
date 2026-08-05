---
name: zellij
description: Open files, diffs, logs, and commands in zellij panes and tabs so a human can review or edit them beside the agent session — `zellij edit` for files, `zellij run` for commands, floating panes for transient review, and layout files for multi-pane grids. Use when asked to open, show, display, or preview something in a pane or tab, to put a file in front of the user for review or editing, to lay out several outputs side by side or as a matrix, to build or replace a tab from a KDL layout, or when a zellij pane/tab command behaves unexpectedly (missing env vars, a pane that hangs the caller, a pane that vanishes, a tab with no tab bar that looks fullscreen, a grid that comes out as an L).
---

# Zellij panes and tabs

Put something in front of a human without taking over their terminal. The agent
keeps its own pane; the file, diff, or command output opens beside it.

Verified against **zellij 0.44.3**. Check `zellij <cmd> --help` when a flag
matters — the CLI has changed shape across releases.

Supporting docs, loaded only when needed:

- `references/flags.md` — the full option matrix.
- `references/grids.md` — three or more panes in a deliberate arrangement:
  the layout-file template, the render-script pattern, and how to verify it.

## The trap that wastes an afternoon

**A new pane does NOT inherit the calling shell's environment.** It inherits the
environment of the zellij *server*, captured when the session started. Anything
you `export` before the call is simply absent:

```sh
export MY_TOKEN=abc
zellij run -- bash -c 'echo "${MY_TOKEN:-UNSET}"'   # prints UNSET
```

The **working directory does** follow the calling shell, which makes the
asymmetry easy to miss — cwd is right, so you assume the env is too.

Three ways through, in order of preference:

1. Pass values in the command string: `zellij run -- bash -c "TOKEN=$MY_TOKEN cmd"`.
2. Wrap in a script that re-establishes the environment itself — for a
   direnv/nix project, have the script run `direnv exec . <cmd>` rather than
   assuming the pane is inside the dev shell.
3. `--cwd <dir>` when the pane must start somewhere other than your cwd.

**Never use `--blocking` or `--block-until-exit*` from an agent.** They block the
caller until the pane closes, so your own tool call hangs until a human closes a
pane they may not know they need to close.

## Opening a file

`zellij edit` is purpose-built and beats `zellij run -- $EDITOR file`: it resolves
`$EDITOR`/`$VISUAL` itself and takes a line number.

```sh
zellij edit path/to/file.ts                      # new pane, biggest free space
zellij edit -d right path/to/file.ts             # split right (or: down)
zellij edit -f path/to/file.ts                   # floating overlay
zellij edit -l 42 path/to/file.ts                # open at line 42
zellij edit --in-place path/to/file.ts           # replace current pane, suspend it
```

Point a reviewer straight at the line you mean — `-l` turns "see the gate in
newsletter.ts" into a cursor already sitting on it.

`$EDITOR` must exist in the **server** environment (see the trap above). If it is
unset there, `zellij edit` cannot fall back to your shell's value.

## Running a command

```sh
zellij run --name build -- npm run build         # named pane, stays after exit
zellij run -c -- ./script.sh                     # --close-on-exit: vanish when done
zellij run -f --name logs -- tail -f app.log     # floating
zellij action new-pane -d right -- bash -c '...' # equivalent, note the `--`
```

- `zellij run <cmd>` and `zellij action new-pane -- <cmd>` do the same job;
  `new-pane` **requires** the `--` separator, `run` accepts it optionally.
- Both print the new pane id (`terminal_<n>`) — capture it if you need to reason
  about what you created.
- **A pane persists after its command exits** unless you pass `--close-on-exit`.
  The dead pane shows the exit status and waits. That is usually what you want for
  review; it is clutter for fire-and-forget.

## Tabs and layout

```sh
zellij action new-tab --name review              # new tab
zellij action query-tab-names                    # list tabs
zellij action dump-layout                        # full tree: tabs, panes, cwd, names
zellij action move-focus left|right|up|down      # move focus before splitting again
```

Build a two-pane comparison by creating the first pane, then splitting from it —
focus follows each new pane, so `move-focus` between splits or everything stacks
in one direction. `--near-current-pane` opts out of focus-following.

**Past two panes, stop splitting and declare a layout file.** Focus-following
makes a grid nearly impossible to build by hand: three `-d right` calls leave
focus on the last pane, so the next `-d down` splits under that one pane and
you get an L instead of a second row. See `references/grids.md`.

### A layout file drops the tab bar unless you ask for it

A tab created with `new-tab --layout <file>` does **not** inherit zellij's
default tab template, so it has no `tab-bar` and no `status-bar` — the tab
strip vanishes and the result reads as "zellij went fullscreen" rather than as
two missing panes. Declare them around your content:

```kdl
tab name="review" {
    pane size=1 borderless=true { plugin location="zellij:tab-bar"; }
    pane split_direction="horizontal" { /* your grid */ }
    pane size=1 borderless=true { plugin location="zellij:status-bar"; }
}
```

Confusingly, a `tab` node in a *session* layout does get the template, so a
user's own layout file can omit these and still show chrome. Only the
`new-tab --layout` path is literal.

`split_direction` names the dividing line: `vertical` gives side-by-side
columns, `horizontal` (the default) gives stacked rows.

`dump-layout` is the only reliable way to confirm what you actually built; it
names every pane and its cwd. Two things it will lie to you about if you let it:

- It serializes command panes with `start_suspended true` regardless of whether
  they are running — that field describes how the layout would *replay*, not
  live state, so do not read it as "the command never started".
- It prints `new_tab_template` and the `swap_*_layout` definitions after the
  tabs, and each carries its own `tab-bar`/`status-bar` entries. An unbounded
  range (`awk '/tab name="x"/,0'`) swallows them and reports chrome your tab
  does not have. Bound the range at `tab |new_tab_template|swap_` —
  `references/grids.md` has the one-liner.

## Choosing pane vs tab vs floating

| situation | use |
| --- | --- |
| one file to review beside the work | `zellij edit -d right` |
| quick look, then gone | `zellij edit -f` (floating) |
| two things compared side by side | new tab, then one split |
| a matrix of three or more | new tab from a layout file (`references/grids.md`) |
| long-running output to glance at | `zellij run -f --name <x>` |
| replace what is on screen, temporarily | `--in-place` |

Prefer a **new tab** once you need more than two panes: a third split makes every
pane too narrow to read wrapped prose or code.

## Cleaning up

There is **no close-pane-by-name**. `zellij action close-pane` closes the
*focused* pane, so an agent cannot safely target one it created — a mis-focused
close can kill the user's own pane or the agent session's pane. Consequences:

- Use `--close-on-exit` for anything you do not want left behind.
- For a pane meant to persist, tell the user it is there and let them close it.
- Do not chain focus-moves and a close to hunt for your pane.

**Tabs, however, are targetable by name** — which is why a tab is the right
unit for anything an agent may need to rebuild or replace:

```sh
zellij action go-to-tab-name "review" >/dev/null 2>&1 && zellij action close-tab
zellij action new-tab --layout /abs/path/layout.kdl
```

The `&&` makes it a no-op the first time and a replacement every time after.

## Validation

- MUST NOT pass `--blocking` / `--block-until-exit*` from a non-interactive agent.
- MUST assume no inherited env; pass what the command needs explicitly.
- SHOULD confirm the result with `zellij action dump-layout` rather than assuming
  the pane opened as intended.
- SHOULD name panes (`--name`) so `dump-layout` is readable afterwards.

## Diagnostics

| symptom | cause | fix |
| --- | --- | --- |
| pane shows "command not found" for a tool that works in your shell | pane has the server's `PATH`, not yours | call by absolute path, or wrap in a script that loads the environment |
| env var reads as empty in the pane | env is not inherited from the caller | interpolate into the command string, or wrap in a script |
| the agent's tool call hangs | `--blocking` / `--block-until-exit*` | drop the flag; it waits for a human to close the pane |
| pane opened but immediately gone | `--close-on-exit` with a command that exited at once | drop the flag, or add a pager/read at the end |
| dead panes accumulating | default is to persist after exit | add `-c`/`--close-on-exit` for throwaway runs |
| `zellij edit` opens nothing usable | `$EDITOR`/`$VISUAL` unset in the server env | set it in the shell profile that starts zellij, then restart the session |
| splits keep stacking one direction | focus follows each new pane | `move-focus` between splits, or `--near-current-pane` |
| a project command fails only in the pane | direnv/nix shell not active there | run it as `direnv exec <dir> <cmd>` inside the pane |
| tab strip gone, tab looks fullscreen | `new-tab --layout` does not inherit the default tab template | declare `tab-bar`/`status-bar` plugin panes in the layout |
| a grid comes out as an L | focus followed the last split, so row 2 nested under one pane | declare the tree in a layout file instead of splitting |
| `dump-layout` shows chrome the tab does not have | the range ran on into `swap_tiled_layout` | bound the awk range at the next tab or swap block |
| text mangled in a narrow grid pane | output written for ~100 columns, pane is a third of that | `fold -s -w "$(tput cols)"` in the render script |
