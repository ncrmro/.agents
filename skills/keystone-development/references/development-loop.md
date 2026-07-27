# Repository and deployment loop

## Source-of-truth boundary

`ncrmro/keystone` owns reusable NixOS and Home Manager integration, the `ks`
installer, templates, storage/security abstractions, and reusable test
harnesses.

`ncrmro/ks-config` owns the fleet's consumer flake, host definitions, stable
hardware paths, fleet policy, secrets wiring, and the locked Keystone revision
used by deployed machines.

Read [design-guidelines.md](design-guidelines.md) when deciding whether
dotfiles, Home Manager, NixOS, or Kubernetes owns a change.

Prefer this dependency direction:

```text
keystone reusable behavior
        ↓
ks-config thin wrapper + host values
        ↓
nixosConfigurations.<host>
```

Do not copy a reusable fix into `ks-config`. Do not put a personal host name,
disk ID, LAN address, or secret into `keystone`.

## Start safely

From each repo:

```bash
git status --short
git branch --show-current
git worktree list
```

Read the root and nearest nested `AGENTS.md`. Existing edits belong to the
user unless proven otherwise.

Resolve the local Keystone checkout with the authoritative
`ks-config/bin/ks-dev` search order and flake lock. `ks-dev` skips checkouts
that lack the locked revision, preventing a silent consumer downgrade.
Remove absolute local paths from deployable lock and input graphs.

## Local override loop

Run from the `ks-config` checkout:

```bash
nix develop --command ./bin/ks-dev --build <host>
nix develop --command ./bin/ks-dev --boot <host>
nix develop --command ./bin/ks-dev --switch <host>
```

- `--build`: first gate; does not activate the result.
- `--boot`: set the next generation for a real reboot. Use for initrd, kernel,
  filesystems, encryption, bootloader, Secure Boot, resume, and risky network
  changes.
- `--switch`: activate immediately only when live activation is safe.

For remote targets, let `ks-dev` resolve `hosts.nix` or the configured SSH
target. Inspect the command implementation before replacing it with an ad hoc
`nixos-rebuild`; it handles local input overrides and remote Nix trust details.

`ks-dev` may open a short-lived root SSH ControlMaster to authenticate with a
Yubi-backed key once per deployment. Close it after deployment and verification.

Use the target, SSH port, and options resolved by `ks-dev`:

```bash
ssh -S "$HOME/.ssh/ks-dev-%C.sock" -O exit root@<resolved-target>
```

Confirm no matching live socket remains:

```bash
find "$HOME/.ssh" -maxdepth 1 -type s -name 'ks-dev-*.sock' -print
```

Close the master through SSH; unlinking its live socket is insufficient.

After activation, verify state and behavior with focused checks such as
`systemctl`, `journalctl`, `bootctl`, storage inspection, or the feature's
actual client.

## Publishing a Keystone change

1. Build and validate through `ks-config` using the local override.
2. Commit and push the owning Keystone branch.
3. In `ks-config`, update only Keystone:

   ```bash
   nix flake update keystone
   ```

4. Confirm `flake.lock` moved to the intended revision.
5. Rebuild the affected host without the local override.
6. Commit the consumer lock update separately.

Never run bare `nix flake update`; unrelated input movement makes failures and
rebuilds difficult to attribute.

## Remote investigation

Start by identifying the host:

```bash
cat /etc/hostname
systemctl list-units --failed
journalctl -b -p warning --no-pager
```

Use read-only checks before restart, switch, wipe, token enrollment, or
firmware changes. If remote sudo cannot acquire a terminal, use an interactive
TTY or a deliberate root deployment path; do not pipe credentials into logs or
commands.

On NixOS, privileged programs such as `sudo` must be entered through
`/run/wrappers/bin`. Executing a raw `/nix/store/.../bin/sudo` bypasses the
setuid wrapper and fails with an ownership/setuid error.

## ks-config-only operations

Follow `ks-config/AGENTS.md` for repository-local operations. For Ocean
Kubernetes resources, use the configured kubeconfig and run
`devenv shell -- k8s-apply-secrets`, then `devenv shell -- k8s-apply`; root SSH
deployment does not apply.

## Canonical implementation surfaces

Inspect these before relying on older narrative docs:

- `ks-config/bin/ks-dev` and `bin/dev-keystone`
- `ks-config/flake.nix`, `flake.lock`, `hosts.nix`, and the target `hosts/`
  directory
- `keystone/modules/`, `lib/templates.nix`, and `packages/ks/`
- `keystone/templates/default/bin/test-iso`
- `keystone/bin/virtual-machine`, `bin/test-e2e`, and
  `bin/test-microvm-tpm`
