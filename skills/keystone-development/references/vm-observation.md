# VM observation: screenshots, serial consoles, and headless driving

Techniques for seeing and driving a Keystone test VM without a display,
distilled from the legacy keystone e2e harness
(`ncrmro/keystone` `docs/testing/iso-os-virtual-machine.md`,
`docs/os/testing-vm.md`, `bin/virtual-machine`) and from ks-fleet /
`vmWithDisko` work.

## QEMU monitor socket: screendump and sendkey

Expose the monitor on a Unix socket at launch
(`--monitor-socket /tmp/e2e-monitor.sock` in the legacy scripts, or
`-monitor unix:/tmp/mon.sock,server,nowait` raw QEMU), then drive it with
socat:

```bash
echo screendump /tmp/stage.ppm | socat - unix:/tmp/mon.sock   # screenshot
echo 'sendkey ret'             | socat - unix:/tmp/mon.sock   # keystrokes
```

- `sendkey` types where no serial console exists (e.g. graphical LUKS
  prompt); send one key per command, `shift-<key>` for capitals.
- **virgl caveat**: with virtio-gpu + virgl, `screendump` returns
  "no surface". Capture Wayland surfaces with `grim` over SSH from inside
  the guest instead; `screendump` remains correct for text/firmware stages
  (LUKS prompt, boot progress).
- Screenshot staging pattern: capture per boot stage (01-luks-prompt,
  02-post-unlock, 03-desktop-or-login, 04-final-state) and byte-compare
  against LFS-tracked baselines (`cmp`); first run seeds the baselines.

## Serial console: LUKS unlock and boot evidence

`console=tty0 console=ttyS0,115200` in kernel params routes the initrd
`cryptsetup-ask-password` prompt onto the serial PTY, so headless runs can
unlock LUKS without a display. The legacy harness ran a background feeder
writing the passphrase to the PTY every 5s until SSH came up — post-unlock
writes are harmless (failed serial getty logins).

For interactive/automated driving of a serial console (e.g.
`system.build.vmWithDisko`'s `disko-vm`), use expect over a pty:

```tcl
set env(QEMU_OPTS) "-nographic"
spawn .../bin/disko-vm
expect -re "Please enter passphrase|passphrase for" { send "secretsecret\r" }
expect "login:" { send "root\r" }
```

`secretsecret` is disko's test-passphrase convention (see `disko.tests`).

## Headless gotchas (hard-won)

- **`-nographic` + closed stdin kills QEMU instantly**: it muxes
  serial+monitor on stdio, and EOF on stdin terminates it. Never run
  `QEMU_OPTS=-nographic run-*-vm </dev/null`; give it a pty (expect) or use
  `-display none -serial file:...` instead.
- **swtpm socket path limit**: `virtualisation.tpm.enable` runners create
  `$PWD/<host>-swtpm/socket.ctrl`; Unix socket paths cap at ~108 chars, and
  overlong paths fail *silently* (error only in `<dir>/stdout`:
  "Path for UnixIO socket is too long"). Set `NIX_SWTPM_DIR=/tmp/<short>`
  (and `NIX_EFI_VARS=/tmp/<short>.fd`) when cwd is deep.
- Stale swtpm state/EFI vars from a crashed run also abort the next run
  silently — remove the state dir and vars file before retrying.
- The NixOS vm runner honors `QEMU_OPTS`, `QEMU_NET_OPTS`
  (e.g. `hostfwd=tcp::2200-:22` to add ssh to a plain `system.build.vm`),
  `NIX_DISK_IMAGE`, `NIX_EFI_VARS`, `NIX_SWTPM_DIR`.

## libvirt tier

VM configs must import `qemu-guest.nix` (virtio driver stack, guest agent,
DRM/KMS) or graphics init fails. Screenshot capture there: `virsh
screenshot`, or grim over SSH for Wayland. Consistent PCI topology between
install and reboot phases keeps device names stable across snapshots.
