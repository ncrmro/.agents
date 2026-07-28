---
name: label-maker
description: Print labels on Brother P-touch (PT-*) label makers from Linux via ptouch-print over libusb, including unprivileged access through udev uaccess rules on NixOS, label geometry and margins, and diagnosis of permission, ordering, and tape failures. Use when setting up a label printer, printing asset or hostname labels, or debugging LIBUSB_ERROR_ACCESS, missing ACLs, or wasted tape.
---

# Brother P-touch label makers on Linux

Brother P-touch label makers have **no Linux CUPS driver**. `ptouch-print` drives
them directly over libusb, which means the whole problem is USB device
permissions plus a bit of label geometry.

Two scripts next to this file encode most of what follows — reach for them
before working through the sections by hand:

| script | does |
| --- | --- |
| `scripts/ptouch-doctor` | Walks the access chain (enumerated → node mode → ACL → group → rule present → rule *ordering* → node newer than ruleset → live open) and names the fix for the first broken link. Read-only, no privileges, prints nothing to tape. |
| `scripts/label-print` | Prints with sane margins, previewing each label and reporting its length in mm first. `--dry` previews without using tape; `-n` chains a batch so the mechanical lead-in is paid once. Confirms `error = 0x0000` afterwards. |

```bash
ptouch-doctor                                  # why can't I print?
label-print --dry art-c3-b5685c                # how much tape will this cost?
label-print -n label-one label-two label-three # batch, one lead-in
```

## The one trap that wastes an afternoon

**A `uaccess` udev rule must live in a file that sorts before
`73-seat-late.rules`.** That file is what consumes the `uaccess` tag and applies
the ACL. On NixOS, `services.udev.extraRules` writes to **`99-local.rules`** —
too late. The rule loads, `udevadm` shows it live, and it silently does nothing:
the device keeps its default mode and gets no ACL.

Ship the rule as a package so you control the filename:

```nix
{ pkgs, ... }:
let
  rules = pkgs.writeTextFile {
    name = "ptouch-print-udev-rules";
    destination = "/etc/udev/rules.d/70-ptouch-print.rules";
    text = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="04f9", ATTR{idProduct}=="<pid>", TAG+="uaccess", GROUP="lp", MODE="0660"
    '';
  };
in
{
  environment.systemPackages = [ pkgs.ptouch-print ];
  services.udev.packages = [ rules ];
}
```

`uaccess` grants an ACL to whoever holds the **active seat session**, so access
follows the login instead of permanently widening a group. Add
`GROUP="lp", MODE="0660"` as a fallback for headless/non-seat logins where no
session owns the seat — unlike `uaccess`, `MODE`/`GROUP` are honoured from *any*
rules file, because udev applies final ownership after all rules run. Put the
target user in `lp` for that fallback to mean anything (the group is normally
empty).

**Agent shells benefit from the ACL**: `uaccess` grants to the *user*, not the
session, so a non-seat shell (ssh, multiplexer, agent harness) running as that
same user is covered — provided someone holds the seat.

## udev rules only fire on device events

After activating the config, **unplug and replug the printer**. A device node
created before the ruleset loaded is never re-evaluated. This is the second
most common reason "the rule is right but it still doesn't work".

Diagnose it by comparing timestamps rather than guessing:

```bash
stat -c '%n owner=%U group=%G mode=%a' /dev/bus/usb/BBB/DDD
stat -c '%y' /run/current-system      # when the new ruleset landed
```

Node older than the generation → replug. `udevadm trigger` also works but needs
root, which defeats the purpose.

## Verify the ACL, not the rule file

The rule being present in `/etc/udev/rules.d/` proves nothing. Check the node:

```bash
getfacl /dev/bus/usb/BBB/DDD | grep '^user:'
# want: user:<you>:rw-   plus mode 0660 from the GROUP/MODE fallback
```

Find the node without `lsusb` (which can return nothing in restricted shells):

```bash
for d in /sys/bus/usb/devices/*/; do
  [ "$(cat $d/idVendor 2>/dev/null)" = "04f9" ] || continue   # 04f9 = Brother
  printf '/dev/bus/usb/%03d/%03d\n' "$(cat $d/busnum)" "$(cat $d/devnum)"
done
```

## Dead ends — don't spend time here

- **A raw CUPS queue.** `lpadmin` will happily create one unprivileged, and the
  CUPS daemon runs as root with device access — but a raw queue still expects the
  P-touch raster protocol on stdin, and `ptouch-print` only speaks it over
  libusb (no raw-dump mode).
- **A CUPS driver queue.** Filters load only from CUPS's `ServerBin`, a
  read-only store path on NixOS; PPDs cannot reference a filter by absolute path.
- **`pkexec`** in a non-interactive shell: needs a polkit agent, and its internal
  agent needs a controlling terminal.

## Printing and label geometry

```bash
ptouch-print --info                                   # tape width, media, error state
ptouch-print --text "label-text"                      # auto-sizes font to the tape
ptouch-print --fontsize 30 --text "small" --pad 40    # explicit size + trailing margin
ptouch-print --force-tape-width=120 --fontsize 30 \
  --writepng preview.png --text "check me"            # preview WITHOUT a printer
```

- **Preview before printing.** `--writepng` with `--force-tape-width` costs
  nothing and saves tape; the auto-chosen font is often far bigger than wanted.
- **`--pad` is positional.** It emits blank tape wherever it appears in the
  argument order, so `--pad N --text X --pad N` brackets the text. `--align`
  does *not* do this — it only aligns multiple lines relative to each other.
- **~25 mm of lead-in is mechanical** and cannot be removed: the print head sits
  that far behind the cutter, so every single label starts with roughly an inch
  of blank tape. Padding *before* the text only adds to it.
- **Batch to stop paying the lead-in per label**: `--chain` skips the final feed
  and cut so a run shares one lead-in; `--precut` puts cuts between labels.
- **Tape width is the cartridge**, not a setting. Font size changes the label's
  *length*, never its width.
- **Confirm each print**: `ptouch-print --info` should report `error = 0x0000`.
  Print commands can exit quietly having done nothing. The printer stays busy
  for a second or two afterwards and answers `--info` with *nothing at all*, so
  retry before concluding the status is unreadable.

Rough scale: at 180 dpi, 40 px ≈ 0.22 in ≈ 5.6 mm.

## Diagnostics

| symptom | cause | fix |
| --- | --- | --- |
| `libusb_open error :LIBUSB_ERROR_ACCESS` | no write access to the USB node | udev rule + replug; verify with `getfacl` |
| rule is live, node still `root:lp 0664`, no ACL | rule sorts after `73-seat-late.rules` | move it to a `70-*` file via `services.udev.packages` |
| rule correct, node still unchanged | node predates activation | replug the printer |
| ACL present for the seat user but a service/daemon can't open it | `uaccess` is per-user | use the `GROUP`/`MODE` fallback |
| printer not found at all | it isn't enumerated | check sysfs for vendor `04f9`; `lsusb` may be unavailable |
| printed text runs into the cut | no trailing pad | `--pad N` *after* `--text` |
| huge blank tape before every label | head-to-cutter distance | unavoidable per label; use `--chain` for runs |
| text far too large | auto font sizing to tape height | set `--fontsize` explicitly, preview first |
| `--writepng` prints no `image size` line | that line only appears on a real print | read the width from the PNG IHDR (uint32 at byte 16) |
| `--info` returns nothing right after printing | printer still busy | retry a few times before reporting a failure |

## Identification

Brother's USB vendor ID is **`04f9`**; the product ID varies per model (e.g.
PT-D460BT is `20e0`). Confirm the model is supported before wiring anything up:

```bash
ptouch-print --list-supported
```

Some P-touch models also have Bluetooth, but `ptouch-print` is USB/libusb only.
