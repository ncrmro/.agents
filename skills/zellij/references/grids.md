# Grids from a layout file

Everything here is for **three or more panes in a deliberate arrangement** — a
matrix of variants, one column per environment, one row per subject. For a
single split, `zellij edit -d right` is still the right tool.

## Why sequential splits cannot build a grid

Focus follows each new pane. Three `new-pane -d right` calls give you a row and
leave focus on the *last* pane, so the next `-d down` splits under that pane
only — you get an L, not a second row. Fixing it with `move-focus` means
tracking focus across every call and hoping nothing else moves it.

Declare the tree instead. A layout file is read as a whole, so the arrangement
cannot come out wrong.

## split_direction semantics

Name the dividing line, not the flow:

| value | dividing line | result |
| --- | --- | --- |
| `vertical` | vertical | panes side by side (**columns**) |
| `horizontal` | horizontal | panes stacked (**rows**) — the default |

So a grid of rows-of-columns is a `horizontal` parent containing `vertical`
children.

## The template

Rows = subject, columns = variant. This is the shape to copy.

```kdl
// A tab built from an explicit layout file does NOT inherit the default tab
// template, so the tab-bar and status-bar panes must be declared here.
// Without them the tab has no chrome and reads as "zellij went fullscreen".
layout {
    tab name="review" {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        pane split_direction="horizontal" {     // rows
            pane split_direction="vertical" {   // row 1: columns
                pane name="a/one" command="/abs/path/render.sh" {
                    args "subject-a" "variant-one"
                }
                pane name="a/two" command="/abs/path/render.sh" {
                    args "subject-a" "variant-two"
                }
            }
            pane split_direction="vertical" {   // row 2
                pane name="b/one" command="/abs/path/render.sh" {
                    args "subject-b" "variant-one"
                }
                pane name="b/two" command="/abs/path/render.sh" {
                    args "subject-b" "variant-two"
                }
            }
        }
        pane size=1 borderless=true {
            plugin location="zellij:status-bar"
        }
    }
}
```

```sh
zellij action new-tab --layout /abs/path/layout.kdl
```

Notes that matter:

- `command` must be an **absolute path**. The pane has the server's `PATH`.
- `args` is a child node, one string per argument — not a flat string.
- Match the host's chrome. Read an existing tab with `dump-layout` and copy the
  `size=` it uses for `status-bar` (1 and 2 both occur in the wild) rather than
  guessing.

## Why the chrome disappears

Zellij applies its `default_tab_template` — which is what supplies the tab-bar
and status-bar panes — to tabs created the ordinary way (`new-tab --name`) and
to `tab` nodes in a *session* layout. A layout file handed to
`new-tab --layout` is taken literally: you get exactly the panes you declared
and nothing else.

This is why a user's own session layout can omit the plugin panes and still
show chrome, while the same KDL passed to `new-tab` does not. The symptom
reads as a display bug ("this is fullscreen somehow?") rather than as two
missing panes, which is what makes it expensive.

## The render script

A pane that shows generated output wants a small wrapper, not a raw command.
Three things it has to do that the caller cannot do for it:

```sh
#!/usr/bin/env bash
set -u
SUBJECT="${1:?}"; VARIANT="${2:-default}"
cd /abs/path/to/project || exit 1

# 1. Re-establish the environment. The pane has the zellij server's env, so a
#    direnv/nix project is NOT active here.
direnv exec . <generate-command> "$SUBJECT" "$VARIANT" >/dev/null 2>&1

# 2. Wrap to the actual pane width. A third-width pane mangles anything
#    written for 100 columns.
fold -s -w "$(tput cols 2>/dev/null || echo 80)" < "out/${SUBJECT}.${VARIANT}.txt"

# 3. Hold the pane open, and say how to close it. Without this the command
#    exits and the pane is a corpse showing an exit status.
printf '\n\e[2m── q to close ──\e[0m\n'
while true; do read -rsn1 k; [ "$k" = "q" ] && break; done
```

Colour-code the variant header (`\e[42;30m` etc.) when the grid's whole purpose
is telling variants apart at a glance.

## Replacing a view idempotently

Panes cannot be targeted by name, but **tabs can**, which makes a tab the unit
of anything an agent might need to rebuild:

```sh
zellij action go-to-tab-name "review" >/dev/null 2>&1 && zellij action close-tab
zellij action new-tab --layout /abs/path/layout.kdl
```

Guarding the close with `&&` means it is a no-op on the first run and a
replacement on every later one. Prefer this over closing panes.

## Verifying what you built

`dump-layout` prints the tab tree **and then** two more things that also contain
`tab-bar`/`status-bar` entries:

```
    tab name="review" { … }      ← what you want
    new_tab_template { … }       ← one chrome triplet
    swap_tiled_layout … { … }    ← several more
    swap_floating_layout … { … }
```

An unbounded range (`awk '/tab name="x"/,0'`) swallows all of it and reports
chrome your tab does not have — a false pass on exactly the check you most want
to trust. It reads as "the chrome is there, so that is not the problem", which
sends you looking somewhere else entirely.

Bound the range at every one of those, not just the next tab:

```sh
zellij action dump-layout \
  | awk '/tab name="review"/{f=1}
         f && /^    (tab |new_tab_template|swap_tiled_layout|swap_floating_layout)/ && !/review/ {exit}
         f' \
  | grep -E 'plugin location|name="'
```

Expect exactly one `tab-bar`, one `status-bar`, and your named panes. Two of
either means the chrome is duplicated; zero means it is missing.

Simplest alternative when the tab's line span is easy to read off: take the
line numbers from `grep -nE '^\s*(tab |new_tab_template|swap_)'` and `sed -n
'<start>,<end>p'`.

That `new_tab_template` block is also the direct answer to why ordinary tabs
have chrome and yours did not: it is the template applied to every tab created
without an explicit layout.
