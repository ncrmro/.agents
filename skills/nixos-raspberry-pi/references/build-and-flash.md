# Build and flash

## Raspberry Pi 4 UEFI layout

Use one GPT disk with these partitions:

1. A FAT ESP of at least 256 MiB.
2. The root partition for the remaining image space.

Copy the Raspberry Pi 4 PFTF firmware to the ESP root. Keep the PFTF
`config.txt`, `RPI_EFI.fd`, Pi firmware blobs, board device trees, and required
overlays together.

Enable these Raspberry Pi settings in `config.txt`:

```text
arm_64bit=1
enable_uart=1
armstub=RPI_EFI.fd
```

Install systemd-boot to the removable fallback path. Set:

```nix
boot.loader.efi.canTouchEfiVariables = false;
boot.loader.systemd-boot.enable = true;
```

Inspect the final ESP. Do not assume that the boot-loader install produced the
fallback binary.

## ARM64 image builds on an x86_64 workstation

Use a native x86_64 Disko image-builder VM. Keep the installed system
`aarch64-linux`. Enable binfmt only for target commands.

This topology is faster than full ARM system emulation because KVM can run the
image-builder VM on the workstation CPU.

Prefer these acceleration paths in this order:

1. Substitute the complete ARM64 closure and image from a trusted binary cache.
2. Build cache misses on a modern native `aarch64-linux` remote builder.
3. Remove optional target runtime dependencies from headless images.
4. Benchmark bounded local `max-jobs` and `cores` pairs.
5. Cross-compile only packages that have a tested cross-build path.

Do not disable production package tests only to shorten an image build.

The Nix `cores = 0` setting gives each derivation the host CPU count.
`max-jobs` still controls the number of concurrent derivations. Benchmark a
bounded pair such as `4/4` and `8/2` on a 16-thread host.

## ZFS root

Use a kernel release that the pinned ZFS package supports.

Set a stable eight-hex-digit `networking.hostId`. Put the storage drivers and
ZFS in the initrd.

A small root pool can use:

```nix
options = {
  ashift = "12";
  autoexpand = "on";
  cachefile = "none";
};

rootFsOptions = {
  compression = "lz4";
  atime = "off";
  xattr = "sa";
  acltype = "posixacl";
  mountpoint = "none";
};
```

Use legacy mountpoints when NixOS mounts the datasets through `fileSystems`.

ZFS adds memory and write load. Consider an ARC limit on a low-memory Pi.
Avoid swap on ZFS unless the design includes the ZFS swap constraints.

## First-boot expansion

A small seed image reduces storage and flash work. Expand these layers in
order:

1. Move the backup GPT header to the physical end of the card.
2. Grow the ZFS partition.
3. Ask the kernel to refresh the partition size.
4. Wait for udev.
5. Run `zpool online -e <pool> <partition>`.
6. Write a durable completion marker only after success.

The expansion unit MUST fail when it cannot resolve the expected partition. It
MUST remain safe to retry.

## Image inspection

Inspect the partition table without attaching the real card:

```sh
sgdisk --print result/<image>.raw
```

Inspect an ESP at a known byte offset with mtools:

```sh
mdir -/ -i result/<image>.raw@@<esp-byte-offset> ::
mtype -i result/<image>.raw@@<esp-byte-offset> ::/loader/loader.conf
```

Confirm the firmware files, fallback EFI binary, kernel, initrd, and loader
entry.

## Sparse block map

Show apparent and allocated sizes:

```sh
du -h <image>.raw
du -h --apparent-size <image>.raw
```

`bmaptool create` can fail on a read-only Nix store directory because its
`SEEK_HOLE` probe creates a temporary file beside the image. Use a temporary
sparse copy:

```sh
image_tmp_dir="$(mktemp -d /tmp/nixos-rpi-bmap.XXXXXX)"
cp --sparse=always <image>.raw "$image_tmp_dir/image.raw"
bmaptool create -o <image>.raw.bmap "$image_tmp_dir/image.raw"
```

Remove only the exact temporary file and directory after the map exists.

Read `ImageSize`, `MappedBlocksCount`, and the mapped percentage from the map.
Keep the map beside the exact raw image that produced it.

## Card preflight

Run both commands immediately before the authorization request and again
immediately before the write:

```sh
lsblk --bytes \
  --output NAME,PATH,SIZE,TYPE,RM,RO,TRAN,VENDOR,MODEL,SERIAL,FSTYPE,LABEL,MOUNTPOINTS

udevadm info --query=property --name=/dev/<whole-disk>
```

Require a stable `/dev/disk/by-id/` link. Resolve it with `readlink -f`.
Reject zero-byte LUNs and mounted partitions.

## Flash

Run this command only after the operator authorizes the exact target:

```sh
sudo bmaptool copy \
  --bmap <image>.raw.bmap \
  <image>.raw \
  /dev/disk/by-id/<authorized-whole-disk>
```

Keep checksum verification enabled. Wait for synchronization. Read the new GPT
back from the same `by-id` path before you remove the card.
