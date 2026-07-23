# Browser flashing (esp-web-tools) + per-device auth

Flash an ESP32 from a web page over **Web Serial**, and provision each device with
its **own** credentials at flash time — so a whole fleet runs one secret-free
binary yet each board authenticates uniquely. The provisioning pattern is
implemented as a small browser-side flasher plus a firmware provisioning
component.

Requirements: **Chrome/Edge on desktop** (Web Serial is not in Safari/Firefox) and
a **secure context** (https or `localhost`).

## Part 1 — how flashing works

1. **Build a single-file factory image.** ESPHome emits it at
   `.esphome/build/<name>/build/firmware.factory.bin` (bootloader + partitions +
   app at offset 0). *Not* under `.pioenvs/` on current ESPHome.
2. **Write an esp-web-tools manifest** next to it:
   ```json
   {
     "name": "My Firmware", "version": "1", "new_install_prompt_erase": true,
     "builds": [{ "chipFamily": "ESP32-S3",
       "parts": [{ "path": "firmware.bin", "offset": 0 }] }]
   }
   ```
   `chipFamily` must match the target (`ESP32`, `ESP32-S3`, `ESP32-C3`, …).
3. **Serve both same-origin** and drop in the button (the import registers the
   custom element):
   ```html
   <esp-web-install-button manifest="/firmware/manifest.json">
     <button slot="activate">Install</button>
   </esp-web-install-button>
   <script type="module">import "esp-web-tools/dist/web/install-button.js";</script>
   ```
   The button requests a serial port, erases + writes, and (with
   `improv_serial:` in the firmware) then offers **Wi-Fi entry in the browser**
   via Improv — so Wi-Fi creds never live in the binary.

That's the whole story if every device may share the same firmware and a shared
(or no) secret. For per-device secrets, add Part 2.

## Part 2 — per-device auth without baking secrets into the binary

The problem: a fleet flashed from one public `.bin` can't carry a per-device token
at compile time, and you don't want one shared token for everyone. The fix:
**flash a secret-free binary, then write a device-specific provisioning frame over
the same serial port**, which the firmware stores to NVS and uses to authenticate.

### The flow (server-mediated)

1. **Mint server-side.** When the operator clicks flash, the dashboard calls its
   backend to create a device row and mint a **per-device key** (random secret);
   the server keeps the hash, returns the key once.
2. **Flash** the shared secret-free factory bin via esp-web-tools' low-level
   `flash()` (dynamic-import it client-side), or the install button.
3. **Reuse the port to provision.** After the chip reboots, open/keep the Web
   Serial port and **write a framed blob** carrying `{ device_id, device_key,
   api_base, … }` (and optionally Wi-Fi). Wait for the firmware's ack line.
4. **Firmware stores + authenticates.** A small custom component parses the frame,
   validates it, and writes the fields to **NVS-backed globals**; on every upload
   the firmware sends `Authorization: Basic base64(device_id:device_key)` (or a
   Bearer token). No compile-time secret, one binary for the whole fleet, unique
   auth per board. Re-flashing re-provisions.

### The wire format (framed, CRC-checked)

Keep it dead simple and verify both ends byte-for-byte:

```
magic   4 bytes   e.g. "PRV1"
version 1 byte    bump when the JSON shape changes
length  4 bytes   big-endian length of the JSON
payload N bytes   UTF-8 JSON: { "device_id", "device_key", "api_base", "wifi"? }
crc32   4 bytes   over payload (or magic..payload); reject on mismatch
\n                trailer so the firmware can frame on newline
```

Browser encoder (TS) and firmware decoder (C++) must compute the **same CRC-32**;
a mismatch is the usual bug. Send over the port after flashing; the firmware logs
an ack (e.g. `provision frame accepted`) that the flasher waits for.

### Firmware side (ESPHome)

- A custom `external_components` component reads bytes from the logger UART /
  USB-CDC, frames on the magic + length, checks CRC, and populates ESPHome
  `globals` declared with **`restore_value: yes`** (flushed to NVS). On boot the
  upload path reads `id(device_key)` etc. — no secret in the source.
- Because Wi-Fi can ride the same frame, you can skip Improv; or keep Improv for
  Wi-Fi and use the frame only for the auth key. Either works.

### Browser side

- Port the low-level flow rather than only the install button: dynamic-import
  `esp-web-tools`' `flash()`, gate on Web Serial support + secure context, show a
  progress/log UI, then after flash **write the frame to the same `SerialPort`**
  and read until the ack. Keep frame encoding in a separate module so browser
  and firmware fixtures can verify the exact same bytes.

### Simpler tiers (pick the least you need)

- **No auth / public data:** shared bin, no frame. Fine for read-only telemetry.
- **One shared token (MVP):** bake a single `Bearer` token via `!secret` and a
  gitignored `.env` (see the main skill). One binary, one token — replace with
  per-device keys later. This is the cheap starting point.
- **Per-device keys:** the frame flow above. Do this once a fleet or untrusted
  ingest makes a shared token unacceptable.
