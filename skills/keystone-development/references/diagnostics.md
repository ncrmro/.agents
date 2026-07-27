# Diagnostic decision guide

Start with evidence from the current boot and current executable. Avoid
changing configuration until the failure layer is identified.

## Build or deploy

### Local Keystone change is ignored

Check `ks-config/bin/ks-dev` output and `flake.lock`. The helper refuses a
local Keystone checkout whose HEAD does not contain the locked revision, and
path-locked inputs have separate handling. Confirm the actual overridden path
before debugging the Nix module.

### Unknown option after publishing

The consumer lock likely predates the Keystone schema change. Push Keystone,
run `nix flake update keystone` in `ks-config`, and rebuild without a local
override.

### Remote copy is untrusted

Remote Nix daemons reject unsigned local paths from untrusted users. Use the
repo deployment helper or root target rather than weakening daemon trust
globally.

### Remote sudo fails or has no terminal

Use a real interactive TTY or the deployment helper's root path. On NixOS,
invoke `/run/wrappers/bin/sudo`; `/nix/store/.../bin/sudo` is not the setuid
entry point and reports that sudo must be owned by uid 0 with the setuid bit.
Do not try to repair a store binary with `chmod`; verify the active generation
and wrapper mount.

## SSH identity

### Host key changed

Distinguish:

- recreated disposable VM: expected, use isolated non-persistent known-hosts;
- installer to installed system: expected only if installed keys differ,
  record the transition;
- same physical machine moving to a new DHCP address: preserve and verify the
  known fingerprint, optionally with `HostKeyAlias`;
- unexplained change: stop before sending credentials or destructive commands.

Never normalize `StrictHostKeyChecking=no` for physical hosts.

## LUKS, FIDO2, and TPM

### FIDO2 token enrolls but boot never prompts

Check that initrd crypttab options include `fido2-device=auto`, rebuild with
`--boot`, and reboot into that exact generation. Confirm the key is visible to
the initrd, not merely installed userspace. Also confirm the enrollment helper
targeted the host's actual encrypted partlabel.

### YubiKey test appears to pass instantly

TPM probably unlocked first. Temporarily wipe or withhold only the TPM token or
hint, retain password and FIDO, and perform an isolated YubiKey reboot test.

### TPM token enrolls but fails after reboot

Enrollment may have happened in the live ISO or kexec PCR state. Boot the
installed signed generation, wipe only the TPM token, and re-enroll there.
Firmware settings or Secure Boot key changes can also invalidate PCR policy.

### Token listing looks correct

`systemd-cryptenroll` or `cryptsetup luksDump` proves metadata, not boot
behavior. Prove each mechanism in a reboot where the other automatic mechanism
is absent.

## Boot and hibernation

### “Starting resume…” then a blinking cursor

Treat this as failed resume even if image write succeeded. Recover with a
one-boot `noresume` argument if a stale image blocks normal boot. Inspect the
previous boot journal, resume device, swap capacity, initrd configuration, and
storage support before retrying.

If hibernation is a requirement, do not silently substitute ZFS for the
approved ext4, LVM, and resume layout.

## Networking and USB Ethernet

### “strictly unmanaged”

The kernel interface exists. Inspect:

```bash
nmcli -f GENERAL,WIRED-PROPERTIES device show <iface>
NetworkManager --print-config
udevadm info /sys/class/net/<iface>
```

Keystone's desktop hypervisor configuration may broadly mark `enp*`
interfaces unmanaged for bridge ownership, which can capture laptop USB
Ethernet. Prefer a targeted upstream bridge-interface option; a host override
should narrow exclusions to the actual VM bridge devices. A transient
`nmcli device set ... managed yes` does not override persistent unmanaged
configuration.

### Ethernet absent from NetworkManager

Check the lower layer:

```bash
ip -brief link
lsusb
journalctl -b -k --no-pager
```

If the USB NIC never enumerated or the port reports “Cannot enable,” no
NetworkManager setting can repair it. Test a physical replug and a narrowly
targeted port or device reset while retaining Wi-Fi. Only then encode a
host-specific recovery service or power quirk, with evidence that it survives
a clean reboot.

Verify both layers across reboot:

1. kernel or USB enumeration and driver binding;
2. NetworkManager ownership, connection, lease, and routes.

### Remote network change

Keep a second path active, prefer `ks-dev --boot` over live switch for risky
changes, and require the host to return after reboot before declaring success.
