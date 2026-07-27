# Remote development on installed hardware

Use this reference for remote work on an installed physical host. For
installation, reinstall, storage design, Secure Boot, hardware enrollment,
Stow recovery, and first-reboot proof, follow the
[bare-metal installation runbook](runbook.baremetal-install.md).

Physical-machine work adds firmware, boot, network, and availability risk. Pin
the hostname, chassis or serial, and SSH host-key fingerprint; an IP address is
not machine identity. Keep a console-capable person present during boot,
encryption, network, suspend, and hibernate changes.

## Stabilize remote access

Prefer Ethernet, but configure and prove Wi-Fi fallback before risky remote
activation. Record both interface names and routes.

Classify network failures before changing NetworkManager:

- Interface exists and says `strictly unmanaged`: inspect NetworkManager
  unmanaged rules, udev properties, and competing network managers.
- Interface is absent from `ip link`: inspect `lsusb`, kernel enumeration,
  driver binding, and USB port errors. NetworkManager cannot manage hardware
  the kernel did not enumerate.
- Link exists without address: inspect carrier, DHCP, VLAN or bridge
  membership, and connection autoconnect.

Keep one working path while repairing the other.

## Activation and reboot gates

Build the host closure in the consumer flake before deployment. Use `--boot`
for initrd, unlock, kernel-command-line, and bootloader changes. Use
`/run/wrappers/bin/sudo` for local elevation; a raw Nix-store sudo binary is not
the setuid wrapper.

After activation, verify the intended booted closure, current system profile,
failed units, storage, and routes. After each bootloader, initrd, or network
change, perform a clean reboot and reconnect using the pinned SSH host
identity. For laptops, separately test:

- boot on AC and battery;
- Wi-Fi fallback and USB Ethernet re-enumeration;
- suspend/resume;
- hibernate/resume, including swap use and prior-boot journal evidence.

A successful hibernation write is not a successful resume. If a stale resume
image blocks boot, use a one-boot `noresume` kernel argument to recover, then
diagnose before retrying.
