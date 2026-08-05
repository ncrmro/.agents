# Zellij CLI flag matrix

Verified against zellij 0.44.3. Re-check with `zellij <cmd> --help`; these
surfaces have moved between releases.

## `zellij edit [OPTIONS] <FILE>`

Opens the file with `$EDITOR` / `$VISUAL`. Returns `terminal_<id>`.

| flag | effect |
| --- | --- |
| `-l, --line-number <N>` | open at a line — use it whenever pointing at a specific spot |
| `-d, --direction <right\|down>` | split direction; omit for the biggest free space |
| `-f, --floating` | floating overlay |
| `--width`, `--height` | floating size, integer or `10%` |
| `--pinned <bool>` | keep a floating pane always on top |
| `-i, --in-place` | replace the current pane, suspending it |
| `--close-replaced-pane` | with `--in-place`, close instead of suspend |
| `--cwd <dir>` | editor working directory |
| `--tab-id <n>` | target a specific tab |
| `-b, --borderless <bool>` | no border (also makes it unmovable by mouse) |
| `--near-current-pane` | open beside the current pane instead of following focus |

## `zellij run [OPTIONS] [--] <COMMAND>...`

Returns `terminal_<id>`. Everything `edit` has, plus:

| flag | effect |
| --- | --- |
| `-n, --name <NAME>` | pane name — makes `dump-layout` readable |
| `-c, --close-on-exit` | close the pane the moment the command exits |
| `-s, --start-suspended` | wait for ENTER before running |
| `--stacked` | open into a stack |
| `--blocking` | **blocks the caller** until the command finishes AND the pane closes |
| `--block-until-exit` | blocks the caller until the command exits or the pane closes |
| `--block-until-exit-success` | as above, on exit status 0 |
| `--block-until-exit-failure` | as above, on non-zero exit |

The four blocking flags are for interactive scripting. From an agent they hang
the tool call until a human intervenes — never use them non-interactively.

## `zellij action new-pane [OPTIONS] [-- <COMMAND>...]`

Same capability as `run`, different entry point. The `--` separator before the
command is **required** here. Without a command it opens a plain shell pane.

## Session and layout introspection

| command | use |
| --- | --- |
| `zellij action query-tab-names` | list tab names |
| `zellij action dump-layout` | full KDL tree: tabs, panes, names, cwd, commands |
| `zellij action new-tab --name <n>` | new tab |
| `zellij action rename-tab <name>` | rename the focused tab |
| `zellij action move-focus <dir>` | move focus before the next split |
| `zellij action close-pane` | close the **focused** pane only |
| `zellij action edit-scrollback` | open the focused pane's scrollback in `$EDITOR` |
| `zellij ls` | list sessions |

`dump-layout` writes `start_suspended true` for every command pane. That reflects
how the layout would replay, not whether the command is running now.

## Environment semantics

| inherited from the calling shell? | |
| --- | --- |
| working directory | **yes** |
| exported environment variables | **no** — comes from the zellij server process |

The server environment is fixed when the session starts. To change what panes
inherit, set it in the shell profile that launches zellij and start a new
session; exporting in a running shell has no effect on new panes.
