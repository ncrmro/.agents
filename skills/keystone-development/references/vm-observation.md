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

## Desktop-session gotchas (Hyprland 0.56 + greetd + uwsm)

- **Hyprland 0.56 autogenerates `hyprland.lua`** when it starts with no
  config, and thereafter *prefers* lua over `hyprland.conf` — even
  `hyprctl dispatch` syntax changes. If a session raced the stow/HM
  activation at first boot, delete the `.lua` AND restart the compositor;
  the provider is chosen at startup (`hyprctl systeminfo | grep
  configProvider` tells you which won).
- **greetd `initial_session` auto-login races home-manager activation** in
  fresh VMs: order greetd `after = [ "home-manager-<user>.service" ]` so
  the stowed config exists before the first session.
- **9p `sharedDirectories` create root-owned parent dirs** (e.g. ~/repos),
  breaking user activation steps. tmpfiles `z` rules DO NOT work here —
  systemd-tmpfiles refuses "unsafe path transition" from a user-owned home
  into a root-owned child. Use a root oneshot instead: `chown` the parents,
  `after = [ "local-fs.target" ]`, `before = [ "home-manager-<user>.service" ]`.
- **`pkill -x Hyprland` misses the uwsm/NixOS-wrapped process name** and
  reports nothing — restart the session via its unit instead:
  `systemctl --user restart wayland-wm@Hyprland.service` (uwsm), and
  expect greetd to need a fresh login afterwards.
- **A screendump after killing the compositor can show a stale
  framebuffer** — a live-looking desktop with a frozen clock. Take two
  dumps a minute apart or check the clock before trusting it.
- vmVariant replaces fileSystems but **not swapDevices/resumeDevice** — a
  physical LVM swap volume hangs boot at "start job running for
  /dev/pool/swap (no limit)"; mkForce them empty in the vmVariant.
- **`-vnc :N` baked into qemu options is incompatible with
  `-display gtk,gl=on`** — for a headed run of a VNC-configured VM, use
  plain `-display gtk` (no GL) or drop the vnc option from the variant.
- **disko image builds with LUKS `passwordFile`** fail inside the image
  builder VM (no one provides the key): give the disk a guarded
  `preCreateHook = "[ -f /tmp/secret.key ] || echo -n secretsecret > /tmp/secret.key"`.
  disko's LUKS type also has `enrollFido2` (enrolls a FIDO2 token at
  format time) and testMode auto-passwords for `askPassword` configs.
- **Pre-seed remote VM hosts** with `nix copy --substitute-on-destination
  --to ssh://user@host` — the target pulls what it can from its own
  substituters; `trusted-users = @wheel` makes it sudo-less.
