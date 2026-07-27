# Browser flashing (esp-web-tools) + per-device auth

Flash an ESP32 from a web page over **Web Serial**, and provision each device with
its **own** credentials at flash time — so a whole fleet runs one secret-free
binary yet each board authenticates uniquely. The provisioning pattern is
implemented as a small browser-side flasher plus a firmware provisioning
component.

Requirements: **Chrome/Edge on desktop** (Web Serial is not in Safari/Firefox) and
a **secure context** (https or `localhost`).

## The non-negotiable browser-build rule

**Any firmware image reachable from a web deployment must be secret-free.**
Authenticating the install page is not enough: static assets are commonly served
before application middleware, and a guessed `/firmware.bin` URL can bypass page
auth. Even when the asset route is explicitly authenticated, secret-free
construction is the defense against a routing regression, cache leak, or copied
artifact.

Keep two explicit definitions when operators also need convenient local burns:

- a local USB YAML may consume gitignored `.env` → `secrets.yaml` values;
- a browser-factory YAML and its entire include graph must contain no `!secret`
  dependency, configured production Wi-Fi, fallback-AP secret, or service token.

If ESPHome requires the browser factory to declare a network, use an
uncredentialed bootstrap AP only to satisfy that schema and omit
`captive_portal`, `web_server`, and `esp32_camera_web_server`. Serial
provisioning does not need those listeners, and leaving them enabled exposes
device or camera surfaces on a publicly knowable fallback network.

Do not try to make one YAML silently switch trust modes based on which secrets
happen to exist. Separate entrypoints make review and clean-CI enforcement
straightforward.

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

A robust concrete contract is:

```text
magic      4 bytes     fixed ASCII
version    1 byte
length     4 bytes     unsigned big-endian JSON byte length
payload    N bytes     UTF-8 JSON, hard-capped (for example 4 KiB)
crc32      4 bytes     unsigned big-endian IEEE CRC-32
trailer    1 byte      newline
```

Define exactly which bytes the CRC covers; `version + length + payload` is a
good choice. Test the browser implementation against the standard
`123456789 → 0xCBF43926` vector, round-trip a fixture, and corrupt one byte to
prove rejection. The firmware state machine must reject unsupported versions,
zero/oversized lengths, malformed JSON, invalid UTF-8 field lengths,
non-HTTPS service URLs, embedded URL credentials, and tokens outside explicit
bounds before changing any state.

### Firmware side (ESPHome)

- A custom `external_components` component reads bytes from the logger UART /
  USB-CDC, frames on the magic + length, checks CRC, and populates ESPHome
  `globals` declared with **`restore_value: yes`** (flushed to NVS). On boot the
  upload path reads `id(device_key)` etc. — no secret in the source.
- Because Wi-Fi can ride the same frame, you can skip Improv; or keep Improv for
  Wi-Fi and use the frame only for the auth key. Either works.
- ESPHome restoring string globals are polling components (normally one-second
  persistence checks). After assigning their values, allow more than one poll
  interval before rebooting (three seconds is comfortable), or explicitly
  persist them. Save Wi-Fi through ESPHome's Wi-Fi preference API rather than
  treating its internal storage like an ordinary string global.
- Apply all values, save them, then emit one value-free acknowledgement. Never
  log SSIDs, URLs containing credentials, tokens, the JSON body, or rejected
  field contents. A warning may identify the failed field/category only.

### Browser side

- Port the low-level flow rather than only the install button: dynamic-import
  `esp-web-tools`' `flash()`, gate on Web Serial support + secure context, show a
  progress/log UI, then after flash **write the frame to the same `SerialPort`**
  and read until the ack. Keep frame encoding in a separate module so browser
  and firmware fixtures can verify the exact same bytes.
- Current esp-web-tools `flash()` disconnects the transport after its hard reset.
  Keep the selected `SerialPort`, wait for native USB to re-enumerate, then reopen
  that same/granted VID+PID port at the application baud rate before writing the
  provisioning frame. Do not pick the first remembered port when multiple ESPs
  may be connected.
- Fetch runtime credentials only after flashing, over an authenticated,
  same-origin `POST` that returns `Cache-Control: no-store`; never put them in
  HTML, DOM attributes, URLs, browser storage, or console output. Zero the
  mutable frame bytes after the serial write.
- Set an acknowledgement deadline and always cancel/release the reader and close
  the application port. Clearing the mutable frame reduces accidental retention;
  immutable JavaScript strings cannot be reliably wiped, so keep their lifetime
  short and drop references immediately after provisioning.

### Static asset routing

For full-stack hosts that serve static files before the Worker/application
router, configure `/firmware/*` to run the Worker first and proxy the asset only
after session authorization. In Cloudflare Workers Static Assets this is
`assets.run_worker_first: ["/firmware/*"]` plus an authenticated handler that
calls the `ASSETS` binding. Keep the binary secret-free anyway.

The authenticated asset response should override static caching with
`Cache-Control: private, no-store`, add `Vary: Cookie`, and set
`X-Content-Type-Options: nosniff`. Whitelist the exact manifest/binary names;
do not turn the authenticated route into an arbitrary asset proxy.

The provisioning endpoint should:

- accept `POST` only;
- require the operator session;
- require the `Origin` header to exactly match the request origin;
- return `Cache-Control: private, no-store` and `Pragma: no-cache`;
- return a generic 503 when required server bindings are absent;
- build image/service URLs server-side and return only the documented fields.

### Clean deployable builds

- Build firmware in its **own CI workflow**, not inside the site build — see
  "Distribution, versioning, and OTA" below for the decoupled pattern. The
  rules here apply to whichever job builds the firmware. Either way, ignored
  generated artifacts must never be an undeclared prerequisite left over from
  a developer machine.
- Pin the same ESPHome/esptool versions locally and in CI, install/cache the
  toolchain in the firmware job, and build from a clean checkout with no
  `secrets.yaml`.
- As defense in depth, scan the output binary for each sufficiently long
  credential present in the local dotenv and fail before publishing on an exact
  match. Give the manifest a content-derived version.
- Run the scan on the exact artifact being published (whether copied into a
  site's public dir or uploaded to object storage), remove both binary and
  manifest on a match, and scan every relevant local/CI token name. Never
  print the credential being searched. A minimum length avoids noisy matches
  for empty or trivial values.
- A clean checkout must succeed without generated `manifest.json`,
  `firmware.bin`, or `secrets.yaml`. Keep generated artifacts ignored, but make
  the firmware CI job regenerate them deterministically.
- If a credential-bearing image was ever public, take the asset offline first,
  rotate every compiled credential (including Wi-Fi/fallback credentials), and
  re-provision affected boards. A code-only fix does not end the incident.

### Simpler tiers (pick the least you need)

- **No auth / public data:** shared bin, no frame. Fine for read-only telemetry.
- **One shared token (trusted-operator MVP):** keep the shared token server-side
  and deliver it after flash through the authenticated/no-store provisioning
  request and serial frame. Never bake it into a browser-served binary. Replace
  it with per-device credentials before devices leave trusted operator custody.
- **Per-device keys:** the frame flow above. Do this once a fleet or untrusted
  ingest makes a shared token unacceptable.

## Synchronous HTTP and the ESPHome watchdog

ESP-IDF DNS/TLS/HTTP calls are synchronous. A client timeout longer than
ESPHome's task watchdog turns an ordinary network stall into a board reset. Give
every uploader both:

1. a bounded HTTP timeout appropriate to its payload; and
2. a scoped `watchdog::WatchdogManager` allowance slightly wider than that
   timeout, so the normal watchdog is restored immediately afterward.

Test an unreachable DNS/TLS endpoint on hardware and verify that one cycle fails
without a reboot.

## End-to-end release checklist

1. Validate both local and browser YAML entrypoints with `esphome config`.
2. Build the browser entrypoint with no secret file in its include graph.
3. Confirm the browser graph has no password, captive portal, generic web
   server, or camera web server.
4. Scan the emitted factory binary for every available real credential without
   printing those values.
5. Verify the manifest version is derived from the emitted binary hash.
6. Build the consuming site from a clean checkout and confirm the binary copied
   into its final static output has the same hash.
7. Confirm firmware paths run through the authenticated application handler and
   that unauthenticated direct requests fail.
8. Flash and provision a physical native-USB board, including disconnect /
   re-enumeration / reopen and a bounded acknowledgement.
9. Stall DNS/TLS/image and telemetry endpoints independently; verify skipped
   cycles rather than board resets.
10. If an older credential-bearing image was ever reachable, deploy containment,
    rotate every embedded credential, and re-provision affected boards. Treat
    code completion and incident closure as separate milestones.

## Distribution, versioning, and OTA (the ESPHome-project pattern)

How the ESPHome org itself ships esp-web-tools firmware (their reusable
workflows in `esphome/workflows`), and the contract the manifest gives you.
Copy this instead of inventing a scheme.

**Decouple firmware builds from site deploys.** Never make a web app's build
shell out to `esphome compile` — an esphome toolchain in every site build is
slow, fragile, and couples unrelated release cadences. Give firmware its own
CI workflow triggered only by firmware paths (plus `workflow_dispatch`), and
publish the artifacts to object storage (ESPHome uses Cloudflare R2). The
site serves the bytes from storage at stable URLs; its build never needs
esphome.

**One manifest, many devices — selection is by chip.** The manifest format
(Part 1) allows multiple `builds[]` entries, one per `chipFamily`, and
esp-web-tools picks the build matching the connected chip automatically. So a
fleet of distinct boards (S3 camera node, C3 sensor node, classic-ESP32 node)
can share one flat `/firmware/manifest.json`; separate manifests are forced
only when two *different products* share a chip family.

**Hosting rules.** The install page must be https (Web Serial requirement).
The manifest and binaries may live on a different origin than the page if
that origin returns `Access-Control-Allow-Origin` for the page's domain;
relative `parts[].path` entries resolve relative to the manifest URL.

**Versioning = immutable dirs + a mutable channel manifest.** Upload each
release as an immutable `<device>/<version>/{manifest.json,*.bin}` tree.
"Promote" by rewriting that version's manifest so every `parts[].path` (and
`ota.path`) gets the `<version>/` prefix, then writing it one level up as
the channel manifest — `manifest.json` for production, `manifest-beta.json`
for beta. The channel manifest is a tiny pointer over immutable artifacts;
rollback is re-promoting an older version. (This is exactly ESPHome's
`promote-r2.yml` jq step.)

**OTA from the same manifest.** ESPHome's `update: platform: http_request`
component consumes the same manifest, extended with a mandatory per-build
`ota` block: `{ "md5": "<hex>", "path": "..." }` (+ optional `release_url`,
`summary`). Devices poll the manifest (default every 6 h), compare the
manifest `version` to their own, then download, MD5-verify, and apply.
Gotchas:

- OTA uses the app-only `firmware.ota.bin`; browser flashing uses
  `firmware.factory.bin` at offset 0. Publish both.
- Serve from a **non-redirecting** origin — redirect targets (e.g. GitHub
  release assets) can overflow the device's default 512-byte URL buffer.
- Path resolution: absolute URLs as-is; `/`-rooted against the manifest's
  host; bare paths relative to the manifest's directory.

**Build-output path gotcha.** ESPHome writes build output under
`.esphome/build/<name>/build/` where `<name>` is the yaml's `esphome: name:`
field — *not* the yaml filename. Scripts that hardcode a directory derived
from the filename break silently when the device name differs; derive the
path from the `name:` field.
