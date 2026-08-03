---
name: nixos-raspberry-pi
description: Build, flash, boot, and diagnose NixOS disk images for Raspberry Pi boards. Use for Raspberry Pi 4 UEFI/PFTF boot, systemd-boot, Disko images, ZFS root pools, x86_64-to-ARM64 builds, sparse SD-card flashing with bmaptool, HDMI capture, serial consoles, LAN discovery, and first-boot validation.
compatibility: Linux build host with Nix. Hardware work can also require bmaptool, ffmpeg, an HDMI capture device, an SD-card reader, Ethernet, and physical access to the Raspberry Pi.
metadata:
  source-of-truth: https://github.com/pftf/RPi4
---

# NixOS on Raspberry Pi

Build a complete removable-disk image. Flash it safely. Observe the complete
boot. Prove storage, network, and service state after the first boot.

Read these references when the task reaches that phase:

- `references/build-and-flash.md` — image design, cross-architecture builds,
  ZFS, build acceleration, and safe SD-card writes.
- `references/boot-observation.md` — HDMI capture, serial, LAN discovery, and
  first-boot checks.
- `references/sources.md` — primary upstream documentation.

## Default decision

Use the native Raspberry Pi firmware path unless the requirement explicitly
needs UEFI.

For a Raspberry Pi 4 UEFI image, use the Pi 4 PFTF firmware on a FAT ESP. Use
the removable `EFI/BOOT/BOOTAA64.EFI` path because the SD card has no persistent
UEFI variables.

Do not use a Raspberry Pi 4 PFTF archive on another Pi generation. Resolve the
board model before you select firmware.

## Safety boundary

An SD-card write destroys the existing partition table and filesystems.

The agent MUST complete all of these steps before a write:

1. Resolve the whole-disk `/dev/disk/by-id/` path.
2. Record its exact byte size, transport, removable flag, model, serial, and
   existing partition labels.
3. Confirm that the path resolves to one removable USB disk.
4. Confirm that no partition is mounted.
5. Show the resolved identity and ask the operator to authorize erasing that
   exact path.
6. Re-run the identity checks immediately before the write.

Do not accept approval for `/dev/sdX`. Device letters can change after a
replug. Do not select a card by capacity alone.

Some multi-slot readers expose one zero-byte LUN and one card LUN with the same
reader serial. Select the nonzero whole disk. Preserve its LUN suffix in the
`by-id` path.

## Workflow

1. Identify the board generation, RAM size, boot medium, firmware path, and
   required boot interface.
2. Choose direct Pi firmware boot or UEFI boot.
3. Define the target as `aarch64-linux`.
4. Define the ESP, root storage, initrd drivers, boot loader, and network.
5. Build the raw image without writing hardware.
6. Inspect the GPT and ESP from the image.
7. Generate a block map for the sparse raw image.
8. Resolve the exact card and obtain erase authorization.
9. Flash with checksum verification.
10. Move the card to the Pi and apply power.
11. Observe HDMI or serial from power-on through login.
12. Discover the host on the LAN.
13. Verify the root pool, pool expansion, boot loader, system state, and SSH.
14. Record what the test proved and what still needs physical validation.

## Required image checks

The image MUST have:

- A valid GPT.
- A FAT ESP for UEFI boot.
- Raspberry Pi firmware files at the ESP root.
- `RPI_EFI.fd` for the Raspberry Pi 4 PFTF path.
- `EFI/BOOT/BOOTAA64.EFI`.
- A kernel, initrd, and boot-loader entry.
- A stable ZFS `hostId` when ZFS is the root filesystem.
- All storage and network drivers needed in the initrd.
- A first-boot expansion path when the image is smaller than the card.

The build MUST complete before the agent asks to erase a card.

## Evidence levels

Keep these claims separate:

- Image evaluation proves NixOS option composition.
- Image inspection proves GPT and ESP contents.
- A successful flash proves that the card accepted verified mapped blocks.
- HDMI or serial proves firmware and kernel progress.
- SSH plus host-side commands proves the installed operating system state.

Do not report a Raspberry Pi boot from image inspection alone.

## Diagnostics

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Disko builds ARM64 packages slowly on x86_64 | QEMU user mode runs target programs | Use a native ARM64 builder or a binary cache |
| One ARM64 test uses little CPU | The target process has little internal parallelism | Do not add more Nix jobs for that derivation |
| Many builds overload the workstation | `max-jobs * NIX_BUILD_CORES` oversubscribes CPUs | Benchmark bounded jobs and cores pairs |
| `bmaptool create` fails beside a Nix store image | Its fallback probe needs a writable directory | Make a temporary sparse copy and create the map there |
| The capture frame shows color bars | The capture device has no HDMI input signal | Check Pi power, HDMI cable, capture input, and Pi HDMI port 0 |
| The second capture node rejects `VIDIOC_G_INPUT` | It is a metadata node | Use the first streaming V4L2 node |
| No `.local` name appears | DHCP or mDNS is not ready | Check the DHCP lease table, ARP neighbors, serial, and HDMI |
| ZFS imports but does not fill the card | The GPT, partition, or vdev did not expand | Check the expansion unit and each layer in order |
| UEFI starts but Ethernet is absent | ACPI or device-tree mode lacks the device | Check PFTF mode, the DT overlay, and the kernel driver |

## Validation

- The skill directory MUST contain this `SKILL.md`.
- The frontmatter MUST contain the exact name `nixos-raspberry-pi`.
- Every destructive command MUST remain behind exact-device authorization.
- The final hardware report MUST include the image commit or source revision.
- The report MUST include the exact card identity used for the flash.
- The report MUST separate build, flash, boot, and runtime evidence.
