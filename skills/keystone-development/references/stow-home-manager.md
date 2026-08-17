# Stow/Home Manager migration traps

Hard-won rules for moving config from HM generation to stow-managed
dotfiles (the ncrmro/dotfiles `packages/` convention: nix provisions
binaries, plain files own behavior).

## Product and dotfiles contract

`ks.systems/terminal` and `ks.systems/desktop` provide starter templates. A
seed command copies missing templates into the user's dotfiles repository. It
MUST NOT replace an existing file unless the user requests `--force`.

After the seed operation, the dotfiles repository owns the editable files.
Normal edits MUST take effect through Stow without a Nix evaluation. A product
change is required only when the dependency set, service wiring, option model,
generated runtime data, adapter contract, or starter default changes.

Terminal owns the canonical theme name and selector. Every theme MUST provide
the complete terminal adapter set, including Zellij. This rule applies to
headless hosts. Desktop depends on terminal and appends graphical adapters and
reload hooks. The selector MUST validate the complete composed adapter set
before it changes any current-theme link.

The product manifest is the machine-readable boundary. Terminal and desktop
template paths MUST NOT overlap. `ks-config` selects the terminal Stow set for
headless users. Desktop users receive that set plus graphical Stow packages.

## Disabling HM file generation — find the real attr key

`<file>.enable = mkForce false` only works on the attrset key the defining
module actually used, and modules are inconsistent:

- Most desktop config: `xdg.configFile."<path-under-.config>"`.
- keystone's `mkHomeRepoFiles` (e.g. zellij layouts): `home.file.".config/..."`.
- HM's zsh module (dotDir): **absolute** keys —
  `home.file."/home/<user>/.zshrc"`.

When a disable silently does nothing (file still in the new
home-manager-files store path), eval the truth:

```bash
nix eval --json '.#nixosConfigurations.<host>.config.home-manager.users.<u>.home.file' \
  --apply 'fs: builtins.filter (n: (builtins.match ".*zsh.*" n) != null) (builtins.attrNames fs)'
```

## Stable slots instead of store paths

Stowed files must never embed `/nix/store` paths. Generation-stable
indirections:

- binaries: bare name on PATH;
- plugin/share assets: `/etc/profiles/per-user/$USER/share/...`
  (requires `home-manager.useUserPackages`);
- session env: `/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh`;
- system share (zsh HELPDIR): `/run/current-system/sw/share/...`.

**`/etc/profiles/per-user` is filtered by `environment.pathsToLink`**: a
package can be in the closure yet invisible in the profile. Add each new
share dir (`/share/oh-my-zsh`, `/share/zsh-syntax-highlighting`,
`/share/zellij`, ...) to `environment.pathsToLink`. Also check actual
package layouts — nixpkgs zsh-autosuggestions now installs to
`share/zsh/plugins/zsh-autosuggestions/`, not `share/zsh-autosuggestions/`.

## Switchover races

A running app can recreate its config the instant HM's link disappears and
before stow links the replacement; stow then aborts on "existing target is
not owned by stow". Recovery: atomically `ln -sfn` the exact relative
symlink stow would create (stow adopts it as its own), then restart
`home-manager-<user>.service`. Hyprland is the worst offender — see
vm-observation.md's desktop-session gotchas for its lua-provider behavior.

## Remote sudo without a tty

`sudo -S` credentials do not persist between commands in a no-tty ssh
session (no tty ticket): wrap the whole privileged sequence in ONE
`sudo -S sh -c '...'`.

## Machine identity when hosts roam

Test machines change addresses (wifi vs dock): before trusting a new
address, verify the ssh host key against the pin in `hosts.nix`
(`ssh-keyscan -t ed25519 <addr>` must match `hostPublicKey`) and only then
add it to known_hosts.

## Cross-repository module identity

Nix deduplicates module imports by source identity. Two repositories can
contain identical option declarations and still produce a duplicate-option
error because their store paths differ.

Each shared option MUST have one declaration in a composed evaluation. Expose
a standalone wrapper that imports its prerequisites, and expose or retain a
core module for a consumer that already imports those prerequisites. Do not
use `_module.args` to decide an `imports` list. That pattern can cause an
import-resolution cycle.
