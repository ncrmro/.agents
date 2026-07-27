# Fast Nix user-profile overrides

Use an isolated Nix user profile as a speed layer for fast-moving CLI packages.
Keep Home Manager or NixOS as the reproducible baseline; let the user profile
temporarily shadow that baseline without rebuilding the host.

## Contents

- [Architecture](#architecture)
- [Use a dedicated profile](#use-a-dedicated-profile)
- [Put commands on PATH safely](#put-commands-on-path-safely)
- [Update-script contract](#update-script-contract)
- [Verify and promote](#verify-and-promote)

Do not use this pattern for system services, kernel or driver packages,
security policy, shared libraries expected by system units, or anything whose
activation belongs to NixOS. It is a user-command delivery mechanism.

## Architecture

Keep the layers explicit:

1. **Declarative baseline:** Home Manager or NixOS pins a known-good version.
2. **Fast override:** a dedicated `nix profile` follows an unlocked package
   flake and wins through user PATH precedence.
3. **Promotion:** after the fast version proves stable, update the intended
   declarative input and deploy normally; then disable the override.

Do not update the repository lock merely to refresh the fast profile. Do not
run standalone `home-manager switch` on a NixOS system with integrated Home
Manager.

## Use a dedicated profile

Keep rapidly updated tools out of the default user profile so upgrades,
history, and rollback are isolated:

```bash
profile="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/fast-tools"
source_flake="github:owner/packages"

mkdir -p "$(dirname "$profile")"
nix profile add --profile "$profile" \
  "${source_flake}#tool-one" \
  "${source_flake}#tool-two"
```

Install from an **unlocked** flake reference. `nix profile upgrade` records and
resolves the latest revision only when the original reference is unlocked; a
reference containing a fixed commit cannot advance.

Upgrade only the isolated profile:

```bash
nix profile upgrade --profile "$profile" --all --refresh
```

Inspect or roll it back without changing the system or Home Manager
generations:

```bash
nix profile list --profile "$profile"
nix profile rollback --profile "$profile"
```

Use upstream binary caches when available. Accept flake-provided configuration
only for a reviewed source; do not apply `--accept-flake-config` blindly to
arbitrary flakes.

## Put commands on PATH safely

A named profile is not automatically added to PATH. Prefer stable links from a
user bin directory that already precedes managed system profiles:

```bash
user_bin="${XDG_BIN_HOME:-$HOME/.local/bin}"
mkdir -p "$user_bin"
ln -s "$profile/bin/tool-one" "$user_bin/tool-one"
```

An automation script must refuse to replace an existing regular file or an
unrelated symlink. It may refresh or remove only links whose exact target is
the profile it owns. This makes disabling the override safe: remove the owned
links and the declarative commands become visible again.

Confirm precedence before relying on it:

```bash
command -v tool-one
type -a tool-one
readlink -f "$(command -v tool-one)"
```

After an install, upgrade, rollback, or override removal, existing terminals
may retain an old command path in the shell hash table. Every script that
changes command resolution must print:

```text
Existing terminals may still have the old command paths cached.
Run `rehash` in each existing terminal, or start a new shell.
```

`rehash` (or `hash -r` in shells that provide it) is the precise operation;
re-sourcing an rc file alone does not necessarily clear cached command paths.

## Update-script contract

A reusable profile updater should:

- maintain an explicit package-to-executable mapping;
- create the profile and install missing packages on its first run;
- upgrade existing elements with `nix profile upgrade --all --refresh`;
- expose `update`, `status`, `rollback`, and `use-system` actions;
- create links only after every expected executable exists;
- preserve unrelated files and links in the user bin directory;
- print package versions and resolved command paths after changes;
- print the existing-terminal `rehash` instruction after any action that
  changes command resolution;
- leave the project `flake.lock`, Home Manager generation, and NixOS generation
  untouched.

Treat this as a deliberate override rather than hidden configuration drift.
Document which script owns it, retain a known-good declarative fallback, and
provide a one-command path back to that fallback.

## Verify and promote

Verification is behavioral, not just a successful profile operation:

```bash
nix profile list --profile "$profile" --json
command -v tool-one
readlink -f "$(command -v tool-one)"
tool-one --version
```

Once the version is accepted, update only the corresponding declarative flake
input, build and activate through the owning Home Manager/NixOS workflow, then
remove the fast-profile links. If the version misbehaves, use
`nix profile rollback` and refresh command lookup in existing terminals.
