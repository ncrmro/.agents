---
name: esp-firmware
description: Develop, build, flash, and debug ESPHome firmware for ESP32 boards (incl. S3 camera nodes) from a devenv-managed toolchain. Use when setting up an ESP32/ESPHome firmware directory, wiring a custom ESPHome component, flashing over USB or the browser (esp-web-tools/Improv), managing Wi-Fi/token secrets, or diagnosing a board that won't compile, connect, or upload.
---

# ESP32 / ESPHome firmware

Build ESP32 firmware declaratively with ESPHome, iterate it from a reproducible
devenv shell, and flash it over USB (CLI) or the browser (esp-web-tools). Covers
the sharp edges that cost the most time: the Nix/PlatformIO toolchain trap, the
dotenv→secrets bridge, the current camera custom-component API, and a Wi-Fi/flash
diagnostics table.

Supporting docs live next to this `SKILL.md`; read them only when needed:

- `references/devenv.md` — the exact devenv (v2) config: pip-esphome, dotenv
  secrets bridge, quick-iterate scripts. Copy this to start a firmware dir.
- `references/camera-uploader.md` — ESP32-S3 camera pin maps and the current
  ESPHome `camera::CameraListener` custom-component pattern for pushing JPEG
  frames over HTTP, plus the two-I²C-bus gotcha.
- `references/web-flasher.md` — browser flashing (esp-web-tools/Web Serial) and
  the per-device **auth-provisioning** pattern (flash a secret-free binary, then
  write a device-key frame over serial).
- `scripts/list-usb-devices` — enumerate attached ESP32 boards (port, kind, MAC,
  chip). Run it when more than one board is plugged in so you flash the right port.

## The one trap that wastes an afternoon

**Do NOT use the nixpkgs `esphome` package to build ESP-IDF firmware.** It fails
in the PlatformIO/pioarduino ESP-IDF step with `idf_tools.py installation failed
… ModuleNotFoundError: No module named 'platformio'` (and a bogus `tool-esptoolpy
does not appear to be a Python project`). ESPHome is designed to manage its own
PlatformIO + ESP-IDF toolchain, so provide it from a **pip venv** (devenv
`languages.python.venv`) instead. See `references/devenv.md`. This is the single
highest-leverage thing in this skill.

## Development environment

Give each firmware directory its **own** devenv so the heavy ESP-IDF toolchain is
isolated from the rest of the repo. Enter with `devenv shell`; the quick-iterate
scripts wrap the ESPHome CLI:

| command | does |
| --- | --- |
| `fw-compile` | `esphome compile <yaml>` — first build pulls ESP-IDF (~minutes) |
| `fw-flash [PORT]` | bridge secrets, then `esphome run … --device <PORT>` (default `/dev/ttyACM0`) |
| `fw-logs [PORT]` | `esphome logs … --device <PORT>` |
| `fw-clean` | `esphome clean <yaml>` |

`esphome config <yaml>` validates schema/pins/custom-component Python **without**
building — always run it first; it's seconds vs. minutes.

## Secrets: dotenv → ESPHome, never in git

Wi-Fi creds and tokens live in a gitignored **`.env`** (devenv `dotenv.enable`
loads it). A `fw-secrets` step generates ESPHome's `secrets.yaml` from those env
vars, so the firmware reads them via `!secret`. Commit only `.env.example`;
gitignore `.env` **and** the generated `secrets.yaml`. Never commit real
credentials — flag it if asked to, and offer to land the convention (example +
wiring) instead. Wi-Fi/PSK is compile-baked, so changing it needs a reflash (or
provision in-browser via Improv — no recompile).

## Quick diagnostics

**Is a board attached? Which port is which?** Run `scripts/list-usb-devices`
(toolchain-free; `-i` adds `esptool chip_id`). It handles both native-USB parts
(`/dev/ttyACM*`, MAC in the by-id name) and UART-bridge parts (`/dev/ttyUSB*`,
CP210x/CH34x/FTDI). With several boards plugged in, list first, then pass the
right port: `fw-flash /dev/ttyACM1`. Raw check:
```
ls -l /dev/serial/by-id/           # Espressif → usb-Espressif_USB_JTAG_serial_debug_unit_*
# sysfs: VID 303a = Espressif; PID 303a:1001 = USB-Serial-JTAG (C3/S3/C6/H2) —
# does NOT identify the chip; `esptool chip_id` confirms it (resets the board).
```

**Wi-Fi won't connect — MEASURE RSSI FIRST.** `reason='Auth Expired'` reads like a
password/router problem but is **usually weak signal**: the device hears the AP
(so the BSSID shows) but its weak transmit can't complete the 4-way handshake.
Set `logger: level: DEBUG` and read the scanned AP's dBm from `fw-logs`:
`- 'ssid' (bssid) ▂▄▆█ Ch:N  -83 dB`. **> −70 works · −80s marginal · −90s dead
(noise floor).** Don't touch config until you know the number.

| log line | usual meaning | fix |
| --- | --- | --- |
| `reason='Auth Expired'` at a **weak RSSI (−85…−95)** | too weak to handshake | **external antenna** / move closer — NOT the password |
| `'4-Way Handshake Timeout'` at a workable RSSI | wrong PSK (got past assoc, key fails) | fix the password |
| `reason='Auth Expired'` at a **strong RSSI** with correct PSK | asymmetric link (weak TX) or PMF/router | external antenna (boosts TX); then PMF/router |
| `'No matching network'` / `'Probe Request Unsuccessful'` | SSID not seen | typo, or **5 GHz-only** — ESP32 is **2.4 GHz only**; also drop `fast_connect` |
| associates then drops after ~40 s | marginal signal (RX ok, TX/handshake stalls) | more signal (antenna/distance) |

Only *after* RSSI is healthy, rule out the secrets bridge: compare the PSK's
**length** at each hop (`.env` → `${#VAR}` in the shell → `secrets.yaml`); a `#` in
the value truncates it (dotenv comment), as do stray quotes/spaces. Report
lengths, never the secret. `power_save_mode: none` / `output_power` / `fast_connect`
/ PMF-disable do **not** fix a signal problem — don't chase them first.

**Weak-antenna boards:** the **XIAO ESP32-S3 Sense** onboard antenna is poor (the
camera board covers the RF) — use the external U.FL antenna. A phone hotspot held
at *inches* is the fastest known-good, strong-signal isolation test.

**Bench AP from an Ethernet box** (isolate the network, give the device a strong
close AP with internet):
```
nmcli device wifi hotspot ifname <wlan> ssid device-bench password <8+chars> band bg
#   → 10.42.0.1/24, dnsmasq DHCP, NAT to the default route. `band bg` = 2.4 GHz.
nmcli connection down Hotspot && nmcli connection delete Hotspot   # teardown
```
If `wlp6s0` shows `unavailable`, `nmcli radio wifi on` first. `key-mgmt` defaults to
`wpa-psk`, PMF off — ESP-friendly. If even a same-room AP reads weak on the device,
that confirms the device antenna, not the router.

**Other common signals:**
- `sensor … marked FAILED` / `Communication failed` — the I²C/other device isn't
  wired or the address/pins are wrong. Non-fatal; the rest still runs.
- Custom component silent — grep logs for its `TAG`; a `[W]…skipping` line means
  it loaded and is gating correctly (e.g. on network).
- Flash: `Permission denied` on `/dev/ttyACM0` → dialout group / udev; `Wrote …
  Hash of data verified` = success.
- First ESP-IDF build is slow and needs network (downloads the toolchain to
  `~/.platformio`); subsequent builds are incremental (~30–60 s + upload).

## Board / chip notes

- A **camera** (`esp32_camera`) needs an **ESP32-S3** (or S2) with **PSRAM** — the
  ESP32-C3 has no camera interface and no PSRAM.
- Native-USB parts (S3/C3/C6) enumerate as CDC on `/dev/ttyACM*` with no USB-UART
  bridge; set ESPHome `logger: hardware_uart: USB_SERIAL_JTAG`.

## Browser flashing + per-device auth

Flash from a web page over Web Serial with esp-web-tools, and provision each board
with its **own** credentials at flash time so a fleet runs one secret-free binary.
Full recipe — factory-bin path, manifest, install button, Improv Wi-Fi, and the
provision-over-serial auth pattern (with the framed-blob wire format) — is in
`references/web-flasher.md`. Requires Chrome/Edge on desktop + a secure context.
