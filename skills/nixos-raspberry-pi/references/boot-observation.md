# Boot observation

## HDMI capture

List V4L2 nodes without optional USB tools:

```sh
for node in /sys/class/video4linux/video*; do
  [ -e "$node" ] || continue
  printf '%s ' "$(basename "$node")"
  tr -d '\n' < "$node/name"
  printf ' -> '
  readlink -f "$node/device"
done
```

Use udev to identify each node:

```sh
udevadm info --query=property --name=/dev/videoN
```

Query supported modes:

```sh
ffmpeg -hide_banner \
  -f v4l2 -list_formats all \
  -i /dev/videoN
```

Capture one frame:

```sh
ffmpeg -hide_banner -loglevel warning \
  -f v4l2 \
  -input_format mjpeg \
  -video_size 1920x1080 \
  -framerate 30 \
  -i /dev/videoN \
  -frames:v 1 \
  -update 1 \
  -y /tmp/nixos-rpi-hdmi.jpg
```

Inspect the frame with the available image-view tool.

Cheap HDMI capture devices often expose two nodes. The first node is usually
the video stream. The second node can reject normal capture operations.

Color bars prove that the capture device works but receives no HDMI signal.
They do not prove that the Pi is off or that its firmware failed.

For a Raspberry Pi 4, use the micro-HDMI port closest to the USB-C power
connector for the first firmware test. Confirm the capture input and cable.

Capture a short video when a still frame can miss a transient error:

```sh
ffmpeg -hide_banner -loglevel warning \
  -f v4l2 \
  -input_format mjpeg \
  -video_size 1920x1080 \
  -framerate 30 \
  -i /dev/videoN \
  -t 60 \
  -c:v copy \
  -y /tmp/nixos-rpi-boot.mkv
```

## Serial fallback

Enable UART in the Pi firmware and add a kernel console parameter such as:

```text
console=ttyAMA0,115200n8
```

Do not connect a 5 V serial adapter to Pi GPIO. Use a 3.3 V adapter and a shared
ground. Record the adapter `by-id` path before you open it.

Serial distinguishes a display-path failure from a firmware or kernel failure.

## LAN discovery

Record the neighbor table before power-on:

```sh
ip neigh show
```

After boot, try the declared mDNS name:

```sh
getent ahosts <hostname>.local
```

If it is absent, check:

1. The router DHCP lease table.
2. New ARP or IPv6 neighbors.
3. The Ethernet link LEDs.
4. HDMI or serial for driver and DHCP errors.
5. The PFTF ACPI or device-tree mode.

Do not identify the Pi only from an unfamiliar address. Match a DHCP hostname,
MAC address, serial observation, or SSH host key.

## First-boot acceptance

Connect over SSH only after you resolve the expected host:

```sh
ssh <admin>@<hostname>.local
```

Run these checks on the Pi:

```sh
systemctl is-system-running
systemctl --failed
findmnt /
findmnt /boot
zpool status
zpool list
zfs list
lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTLABEL,MOUNTPOINTS
bootctl status
journalctl -b -p warning
```

For a first-boot expansion unit, also run:

```sh
systemctl status <expansion-unit>
journalctl -b -u <expansion-unit>
```

The root pool size SHOULD approach the physical card capacity after expansion.
The pool MUST be healthy. The system MUST have no failed required units.

Reboot once. Prove that UEFI selects the installed loader without an installer,
the pool imports without manual input, Ethernet returns, and SSH accepts a new
connection.
