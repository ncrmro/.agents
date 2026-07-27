# Keystone virtual-machine validation

Use the cheapest tier that contains the subsystem under test. Run commands
from the repo that owns the harness and inspect `--help` first; older docs
describe scripts that have since evolved.

## Tier map

| Tier | Covers | Does not cover |
| --- | --- | --- |
| Evaluation/build | Nix evaluation and closure construction | Runtime behavior |
| TPM microVM | TPM device, LUKS token enrollment/unlock logic | UEFI, Secure Boot, PCR 7 |
| `build-vm` | Fast terminal/desktop module behavior | Real disko install, Secure Boot, physical devices |
| Direct qcow2 | Storage, initrd, encrypted boot, VM UEFI/TPM | Installer TUI and ISO handoff |
| Full ISO/libvirt | Automated installer, disko, password-LUKS, screenshots, SSH; environment permits manual OVMF/TPM tests | Automated run does not itself prove Secure Boot state, PCRs, TPM enrollment/unlock, or physical hardware |

## Tier 1: TPM microVM

The `ks-config` VM fleet wraps the Keystone test:

```bash
devenv up vm-tpm-microvm
```

Or run the owning harness:

```bash
nix develop --command ./bin/test-microvm-tpm
```

This is the fast test for loopback LUKS plus swtpm. It is never evidence for
Secure Boot or PCR 7.

Read bounded logs rather than following forever. Clean shutdown matters:
orphaned swtpm sockets and processes make later failures misleading.

## Tier 2: build-vm

Use each repo's own `bin/build-vm`; the scripts are not interchangeable.

- Keystone's script targets its test-flake terminal and desktop fixtures.
- ks-config's script accepts consumer `nixosConfigurations`.

This tier is for service, terminal, and desktop iteration. It deliberately
omits full disk installation, encryption, and Secure Boot. Use `--build-only`
as an initial gate and `--clean` only after resolving exactly which persistent
qcow2 and PID files it removes.

Both current `build-vm` scripts use fixed TCP port 2222 and may terminate the
process that owns it. Before running either script, inspect the listener:

```bash
ss -ltnp 'sport = :2222'
```

Proceed only if the port is free or the owner is the exact stale VM being
replaced. Stop that VM by its recorded PID or lifecycle command. Do not allow
the harness to kill an unrelated process; repair the harness or choose another
tier if ownership is uncertain.

Ephemeral VM SSH can disable host-key persistence because recreated guests
change identity by design. Never carry those relaxed SSH flags over to real
hardware.

## Direct qcow2 path

For storage, initrd, or boot-chain changes below the installer, prefer the
current direct-image path. From the Keystone repo, use the fixture-generating
entry point:

```bash
nix develop --command ./bin/test-e2e --direct <host> --headless
```

From a consumer flake generated from Keystone's default template, use its
copied test harness:

```bash
nix develop --command ./bin/test-iso --direct <host> --dev --headless
```

The consumer flake exposes `vm-image-<host>` packages through
`keystone.lib.mkVMImage`. Disko remaps physical storage declarations to
virtual disks. The path boots the installed image under Q35, OVMF, and swtpm
and is substantially faster than reinstalling from ISO.

Use a SPICE window by dropping `--headless` when serial evidence is
insufficient. Treat an auto-fed test passphrase as fixture data only; never
reuse it on real hardware.

## Full ISO and installer path

Use the full e2e path when the changed behavior is baked into the ISO or
belongs to installer interaction:

```bash
nix develop --command ./bin/test-e2e
```

ISO rebuild required:

- `ks` binary;
- installer NixOS modules;
- live-environment packages;
- embedded configuration snapshot.

Usually no ISO rebuild required:

- modules evaluated during `nixos-install`;
- template library or host definitions consumed at install time;
- host-side `test-iso` orchestration.

The current Keystone reference is
`docs/testing/iso-os-virtual-machine.md`. Use `bin/virtual-machine --help` for
lifecycle flags. Treat `docs/os/testing-vm.md`,
`docs/os/testing-procedure.md`, and `bin/test-deployment` as legacy unless
their current implementations are the explicit target.

A green automated e2e run proves the checks it actually performs: installation,
password-based LUKS handoff, screenshots/checkpoints, and SSH readiness. To
claim Secure Boot or TPM success, add explicit guest checks for `bootctl` or
`sbctl`, LUKS token state, and an isolated reboot that exercises TPM unlock.

## Secure Boot and snapshots

A new full-stack VM starts with Secure Boot-capable OVMF in Setup Mode. Verify
the transition:

```text
before enrollment: Secure Boot disabled (setup), Setup Mode setup
after enrollment:  Secure Boot enabled (user),  Setup Mode user
```

TPM state and OVMF NVRAM are stateful. Resetting only the qcow2 disk does not
necessarily reset either. Use the harness's reset or setup-mode operations
when testing first enrollment.

Snapshot only stopped, consistent images. Useful checkpoints:

- `post-install`: installed disk before first normal boot;
- `post-unlock`: boot chain and LUKS proven;
- a named feature checkpoint before incremental rebuilds.

Restore a checkpoint for module iteration; delete or reinstall when testing
partitioning or installer behavior itself. Use exact process and VM identity;
never use broad `pkill` or delete all qcow images as cleanup.

## VM completion checklist

- The selected tier actually contains the changed subsystem.
- Guest configuration imports the required QEMU guest profile and drivers.
- SSH readiness is followed by feature-level checks.
- Secure Boot is checked inside the guest when claimed.
- TPM tests distinguish token enrollment from unlock across a reboot.
- VM, swtpm, monitor socket, PID file, ControlMaster, and port ownership are
  cleaned up.
- Any retained snapshot or disk is named and reported.
