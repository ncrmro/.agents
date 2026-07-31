---
name: keystone-development
description: Develop, architect, install, deploy, test, and diagnose Keystone OS through the ks.systems/os platform repo, ncrmro/ks-config consumer flake, and ncrmro/dotfiles. Use for ks-dev build/switch workflows; deciding whether dotfiles, Home Manager, NixOS, or Kubernetes owns a change; local Keystone module iteration; remote NixOS work on real hardware; nixos-anywhere and disko installs; Secure Boot and LUKS enrollment; or build-vm/direct-image/libvirt/microVM testing.
---

# Keystone development

Treat `ks.systems/os` as the reusable platform and `ks-config` as the fleet consumer
and deployment entry point. Start with the lowest validation tier that can
exercise the behavior; use real hardware only for behavior that depends on
physical firmware or devices.

## Load the relevant reference

Read only the references required for the task:

- Architecture ownership, dotfiles/Home Manager boundaries, NixOS, and
  Kubernetes service placement:
  [references/design-guidelines.md](references/design-guidelines.md)
- Repository ownership, local overrides, deployment, and lock updates:
  [references/development-loop.md](references/development-loop.md)
- Destructive installation or remote work on a physical host:
  [references/real-hardware.md](references/real-hardware.md)
- End-to-end physical installation, Secure Boot, LUKS enrollment, Stow
  activation, and reboot proof:
  [references/runbook.baremetal-install.md](references/runbook.baremetal-install.md)
- Booting, deploying, or smoke-testing fleet hosts as VMs, baremetal, or a
  mix — the current harness (realizations, fleetMeta, remote vm hosts,
  disko install tier): [references/ks-fleet.md](references/ks-fleet.md)
- Any VM, microVM, direct image, ISO, Secure Boot, or TPM test (legacy
  tiers): [references/virtual-machines.md](references/virtual-machines.md)
- Watching or driving a headless VM — screenshots (screendump/grim), serial
  console LUKS unlock, QEMU monitor sendkey, expect scripting, swtpm gotchas:
  [references/vm-observation.md](references/vm-observation.md)
- Migrating config from Home Manager generation to stow — attr-key traps,
  stable profile slots vs store paths, switchover races, remote sudo:
  [references/stow-home-manager.md](references/stow-home-manager.md)
- Boot, unlock, SSH, sudo, USB, or networking failures:
  [references/diagnostics.md](references/diagnostics.md)

When documentation conflicts with executable behavior, follow the current
script's `--help` and implementation. If authorized, update the owning
repository's documentation in the same change.

## Establish context

Before editing or deploying:

1. Locate both checkouts and read every applicable `AGENTS.md`.
2. Inspect branch, worktree, and dirty state in each repo. Preserve unrelated
   work.
3. Identify the target host or VM configuration and its flake output.
4. Decide which repo owns the change:
   - reusable option, module, template, installer, or test harness → `keystone`
   - editable user configuration payload → `dotfiles`
   - host hardware, fleet policy, secrets wiring, or per-user override →
     `ks-config`
   - application image and Kubernetes workload definition → the application
     repository
5. Enter the repo's Nix environment. Prefer
   `nix develop --command <command>`; do not install tools globally or use
   `npx`.

When both repos mention a feature, implement its behavior in the repository
identified by step 4. Limit `ks-config` to host selection, fleet policy, secrets
wiring, and per-user overrides.

## Choose the validation tier

| Need to prove | First choice |
| --- | --- |
| Pure evaluation, formatting, or a host closure | `ks-dev --build <host>` or `nix build` |
| TPM/LUKS logic without UEFI | TPM microVM (Tier 1) |
| Terminal or desktop configuration without real disk/security | ks-fleet vm realization (`--as vm`) |
| Storage, initrd, LUKS/TPM unlock below the installer | ks-fleet install realization (disko image + swtpm) |
| Installer TUI, disko handoff, or manual Secure Boot/TPM proof | full ISO + libvirt VM plus explicit guest checks (Tier 3) |
| Firmware, physical TPM/YubiKey, suspend, hibernate, dock, or USB behavior | real hardware |

Move upward only when a lower tier cannot exercise the behavior. The TPM
microVM direct-boots a kernel without UEFI, so it cannot prove Secure Boot or
PCR 7 coverage.

## Core development loop

For a Keystone change consumed by a `ks-config` host:

1. Edit the local `keystone` worktree.
2. From `ks-config`, build with the local override:

   ```bash
   nix develop --command ./bin/ks-dev --build <host>
   ```

3. Run the smallest relevant VM tier.
4. For a local physical host, prefer the agent-build/human-switch handoff in
   `references/development-loop.md`: the agent proves and reports the exact
   closure, then the human activates it with `nixos-rebuild --store-path`.
5. Use `--boot` for boot/initrd changes; use `switch` only for changes that are
   safe to activate live.
6. After a successful activation, verify the runtime behavior and that the
   live system and system profile both resolve to the intended closure.
7. Commit and push Keystone first when publishing. Then update only the
   `keystone` input in `ks-config`, rebuild, and commit the lock update.

Never run a bare `nix flake update` in `ks-config`. Update only the intended
input.

## Real-hardware gates

For an installation or reinstall, follow the
[bare-metal installation runbook](references/runbook.baremetal-install.md).
Before crossing the hardware boundary, pin machine identity, resolve the
physical disk through a stable ID, record explicit erase authorization, and
keep a console-capable person present.

Preserve a working LUKS passphrase throughout hardware enrollment. Choose
TPM-only or FIDO2-plus-TPM policy explicitly; never let TPM mask an independent
FIDO2 test. Token metadata is not boot evidence, so require a real reboot that
proves the selected unlock path and returns over a verified network route.

## Completion criteria

Before reporting success:

- the intended repo owns the change and unrelated edits remain untouched;
- the host/VM closure builds in the consumer flake;
- the selected validation tier exercises the changed behavior;
- destructive actions and credential transitions have explicit evidence;
- boot/security changes survive an actual reboot where applicable;
- temporary VMs, sockets, PID files, and test artifacts are cleaned up unless
  the user asked to retain them;
- published Keystone changes are followed by a targeted consumer lock update.
