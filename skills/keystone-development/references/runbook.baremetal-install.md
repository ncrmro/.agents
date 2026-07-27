# Bare-metal installation runbook

Use this runbook for installing or reinstalling Keystone on physical hardware,
including encrypted storage, Secure Boot, hardware-backed unlock, remote
handoff, and Stow activation.

Enroll the TPM only after booting the installed, signed generation, never from
the installer or kexec environment. An enrollment table proves metadata; only
a reboot proves automatic unlock.

## 1. Establish the operating boundary

Before changing the host:

1. Locate the Keystone platform and fleet-consumer checkouts.
2. Read their applicable `AGENTS.md` files and inspect branch, worktree, and
   dirty state.
3. Identify the host's flake output and which repository owns each required
   change.
4. Confirm that a console-capable person is present for disk, boot,
   encryption, network, suspend, and hibernate transitions.
5. Record explicit authorization for the exact physical disk before erasing
   anything.

Do not turn a deployment request into permission to erase an unresolved disk.
Do not ask a user to paste sudo, LUKS, FIDO2, or recovery credentials into
chat.

## 2. Pin machine identity and network access

Record the hostname, chassis or serial, addresses, routes, and SSH host key:

```bash
hostname
cat /sys/class/dmi/id/product_name
cat /sys/class/dmi/id/product_serial
ip -brief address
ip route
ssh-keyscan -t ed25519 <address>
```

An IP address is not identity. When a known physical host moves to a new DHCP
address, verify its pinned fingerprint before connecting. Use
`StrictHostKeyChecking=yes` and, when necessary, `HostKeyAlias=<old-address>`
to reuse the pinned identity without weakening verification.

Prefer Ethernet, but prove Wi-Fi fallback before a risky activation. Keep one
working route while changing the other.

## 3. Inventory and preserve state

Record storage, firmware, unlock-device, and hibernation state:

```bash
lsblk -e7 -o NAME,PATH,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS
readlink -f /dev/disk/by-id/*
findmnt
swapon --show
bootctl status
systemd-cryptenroll --tpm2-device=list
systemd-cryptenroll --fido2-device=list
```

Resolve the installation target through `/dev/disk/by-id/`; never authorize
erasure from `/dev/nvme0n1` or `/dev/sda` alone.

For a reinstall, preserve and verify before erasure:

- `/var/lib/sbctl` and its ownership and modes;
- `/etc/ssh/ssh_host_*` and its ownership and modes;
- uncommitted dotfiles or Stow packages;
- hashes and an off-disk, encrypted copy of every private artifact.

An archive that has not been opened, listed, and hash-checked from its
surviving location is not a recovery plan.

Treat hibernation as a storage requirement. Provision persistent resume swap
inside the encrypted storage layout and size it explicitly. Use a root layout
with proven resume support; LUKS → LVM → ext4 is the default when no other
layout has passed an end-to-end resume test. Inspect the host's
`disk-config.nix`, `hardware-configuration.nix`, boot options, and resume
configuration together.

## 4. Build before installing

Enter the consumer repository's Nix environment and build the host closure:

```bash
nix develop --command \
  nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

Evaluate the security- and resume-sensitive values directly:

```bash
nix eval --json \
  .#nixosConfigurations.<host>.config.boot.initrd.luks.devices
nix eval --raw \
  .#nixosConfigurations.<host>.config.boot.resumeDevice
```

For a Disko install test, size the sparse test image for the declared swap,
ESP, and usable root filesystem. If the test disk is smaller than the
hibernation LV, enlarge the test disk; the physical layout may still be valid.

Use `--boot`, not a live switch, for initrd, storage-unlock, kernel-command-line,
or bootloader changes.

## 5. Install and preserve identity

Check the current `nixos-anywhere --help`, then run it from the fleet consumer
against the authorized `/dev/disk/by-id/` target. Let Disko manage the declared
filesystems; diagnose a partial installation before hand-formatting anything.

Separate kexec, Disko, install, and reboot phases when Secure Boot or SSH
identity must be restored under `/mnt`. Before first reboot:

1. Restore the preserved Secure Boot and SSH host identities.
2. Verify ownership, modes, and recorded hashes.
3. Verify the signed EFI or unified-kernel artifacts.
4. Remove temporary LUKS key files when their phase is complete.
5. Record the expected installed-system SSH fingerprint.

Expect a host-key transition only when the installed identity intentionally
differs from the installer. Never normalize
`StrictHostKeyChecking=no` for a physical host.

## 6. Verify the installed first boot

Boot the installed system with the LUKS passphrase and collect:

```bash
hostname
cat /proc/sys/kernel/random/boot_id
readlink -f /run/booted-system
readlink -f /run/current-system
readlink -f /nix/var/nix/profiles/system
cat /proc/cmdline
findmnt -no SOURCE,FSTYPE,OPTIONS /
swapon --show
lsblk -e7 -o NAME,PATH,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS
bootctl status --no-pager
systemctl --failed
ip -brief address
ip route
```

Verify the setuid sudo wrapper:

```bash
stat -Lc 'uid=%u mode=%a path=%n' /run/wrappers/bin/sudo
find -L /run/wrappers/bin/sudo -prune -user root -perm -4000 -print
```

If `/run/booted-system`, `/run/current-system`, and the system profile differ,
compare their closures before changing anything:

```bash
nix store diff-closures /run/current-system /run/booted-system
diff -ru --no-dereference \
  "$(readlink -f /run/current-system)" \
  "$(readlink -f /run/booted-system)"
```

When activating an already-built closure without `nixos-rebuild`, update the
root system profile before installing its boot entry:

```bash
sudo nix-env \
  --profile /nix/var/nix/profiles/system \
  --set <validated-closure>
sudo <validated-closure>/bin/switch-to-configuration boot
```

Calling `switch-to-configuration boot` alone does not move the system profile.
A newer profile generation may remain the firmware default and select a
different initrd on reboot. Verify `/run/booted-system`,
`/run/current-system`, and `/nix/var/nix/profiles/system` after the reboot.

## 7. Activate and prove Stow

Clone the intended dotfiles branch before Home Manager's Stow activation, or
rerun activation after cloning. A warning-only skipped Stow step is not
success.

For each expected package:

1. Diff recovered content against the repository.
2. Keep package boundaries and exclude caches, credentials, and generated
   machine state.
3. Resolve pre-existing targets deliberately.
4. Dry-run Stow against the real home directory.
5. Activate through the repository's Home Manager or Stow integration.
6. Verify the final links resolve into the intended checkout:

```bash
ls -ld ~/.config/<target>
readlink -f ~/.config/<target>
```

## 8. Select an unlock policy

Always retain a tested password slot. Choose one policy explicitly.

### TPM now, FIDO2 deferred

Use for TPM-backed unattended boot when FIDO2/YubiKey recovery is deferred.

The initrd must include:

```nix
crypttabExtraOpts = [ "tpm2-device=auto" ];
```

Boot the installed signed generation with the passphrase. Verify Secure Boot,
TPM availability, the exact LUKS device, and the booted closure. Remove only a
stale TPM token, if present, then enroll against the installed PCR state:

```bash
# Inspect first; run the wipe only when a stale TPM2 entry is present.
sudo systemd-cryptenroll <luks-device>
sudo systemd-cryptenroll --wipe-slot=tpm2 <luks-device>
sudo systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrs=1+7 \
  <luks-device>
sudo systemd-cryptenroll <luks-device>
```

Do not wipe password slots. Record FIDO2 as deferred work, not as completed
recovery.

### FIDO2 and TPM

Use this when both independent hardware paths are in scope. The initrd must
include both:

```nix
crypttabExtraOpts = [
  "fido2-device=auto"
  "tpm2-device=auto"
];
```

Prove the mechanisms independently:

1. Boot the installed signed generation with the passphrase.
2. Withhold or remove only TPM enrollment so it cannot mask the FIDO2 test.
3. Enroll one FIDO2 key without `--wipe-slot`.
4. Reboot with the key and prove PIN/touch unlock.
5. Reboot without the key and prove password fallback.
6. Enroll TPM from that installed boot state.
7. Reboot without the key and prove TPM unlock.

The final token table contains password, FIDO2, and TPM2 entries.

## 9. Handle interactive credentials on the host

When the required hardware key is available, run the deployment helper through
root SSH. Otherwise use a real local TTY and `/run/wrappers/bin/sudo`.

For a remote session without root SSH:

1. Verify the ordinary-user SSH identity and active graphical or console
   session.
2. Put a helper in `/tmp` containing only the identity checks, enrollment
   command, and non-secret logging, then review its full contents.
3. Make it refuse the wrong hostname, booted closure, Secure Boot state, or
   block device.
4. Have it preserve the password slot, display token tables before and after,
   and log only non-secret output under `/var/tmp`.
5. Present the helper in a terminal on the physical host so the user types
   sudo and LUKS credentials locally.
6. Never send keystrokes, credentials, raw volume keys, or recovery material
   through chat or automation.

Do not reinterpret a failed `sudo -n` as permission to weaken sudo, enable
passwordless elevation, or bypass LUKS authorization.

## 10. Reboot and prove the result

After enrollment, reboot with every other automatic unlock mechanism absent.
Monitor the pinned SSH identity and require:

- a changed boot ID;
- the host returning on an expected network path;
- the intended booted closure and profile;
- Secure Boot and measured boot still enabled;
- no failed system units;
- the encrypted root and resume swap mounted as designed;
- expected Stow links still resolving;
- a token table that retains password recovery and the selected hardware
  token.

If the host does not return, use the local console and password fallback. If a
stale hibernation image blocks boot, append `noresume` for one boot and diagnose
resume before retrying.

Check network and SSH separately during a slow reboot. No ping response can
still indicate firmware, unlock, or network startup. If ping succeeds but SSH
does not, the encrypted root has opened and network startup has progressed;
wait for SSH or inspect that service locally instead of treating the first SSH
timeout as a TPM failure.

## Completion evidence

Do not report completion until the transcript contains:

- pinned physical-host identity and current network path;
- explicit authorization for any erased disk;
- successful consumer closure build;
- installed storage, Secure Boot, sudo, and resume evidence;
- direct Stow target resolution;
- enrollment metadata preserving the password slot;
- a real reboot proving the selected unlock path;
- cleanup of temporary helpers, control sockets, and installation secrets.
