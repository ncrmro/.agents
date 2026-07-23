# ESP32-S3 camera + HTTP-upload custom component

How to capture JPEG frames on an ESP32-S3 and POST them somewhere on an
interval, using the **current** ESPHome camera API (refactored into a
`camera::` base namespace with a listener interface).

## Two I²C buses (the gotcha)

If you use both the camera and I²C sensors, you get:
`The 'i2c_pins:' config option is incompatible with a dedicated 'i2c:' block, use
'i2c_id' instead.` The camera's SCCB is an I²C bus; declare buses as a **list**
with ids and point the camera at one with `i2c_id`:

```yaml
i2c:
  - id: cam_i2c
    sda: GPIO40      # camera SCCB (SIOD/SIOC)
    scl: GPIO39
    scan: false
  - id: sensor_i2c
    sda: GPIO5       # your sensors on free pads
    scl: GPIO6
    scan: true

esp32_camera:
  i2c_id: cam_i2c    # NOT i2c_pins
  # …pin map below…

sensor:
  - platform: bh1750
    i2c_id: sensor_i2c
    # …
```

## XIAO ESP32-S3 Sense camera pin map (OV2640)

```yaml
psram:
  mode: octal
  speed: 80MHz

esp32:
  board: esp32-s3-devkitc-1
  flash_size: 8MB
  framework: { type: esp-idf }

esp32_camera:
  id: cam
  external_clock: { pin: GPIO10, frequency: 20MHz }
  i2c_id: cam_i2c
  data_pins: [GPIO15, GPIO17, GPIO18, GPIO16, GPIO14, GPIO12, GPIO11, GPIO48]
  vsync_pin: GPIO38
  href_pin: GPIO47
  pixel_clock_pin: GPIO13
  resolution: 800x600
  jpeg_quality: 12
  max_framerate: 5 fps
```

`esp32_camera_web_server: [{ port: 8080, mode: snapshot }]` gives a local still
endpoint (bench debugging / a host-side pull uploader).

## Custom component: POST a frame on an interval

The camera API is listener-based. Include `http_request:` in the YAML so the
mbedTLS **cert bundle** is compiled in (needed for `esp_crt_bundle_attach` on
HTTPS). Depend on `["esp32_camera", "network", "http_request"]`.

Header — inherit `PollingComponent` **and** `camera::CameraListener`:

```cpp
#include "esphome/core/component.h"
#include "esphome/components/camera/camera.h"
#include "esphome/components/esp32_camera/esp32_camera.h"

class Uploader : public PollingComponent, public camera::CameraListener {
 public:
  void set_camera(esp32_camera::ESP32Camera *c) { camera_ = c; }
  void setup() override;
  void update() override;   // fires each poll interval
  void on_camera_image(const std::shared_ptr<camera::CameraImage> &image) override;
 protected:
  esp32_camera::ESP32Camera *camera_{nullptr};
  bool pending_{false};
};
```

Key calls (source of the names: the installed headers under
`.esphome/build/<name>/src/esphome/components/{camera,esp32_camera}/`):

- `camera_->add_listener(this);`            // in setup()
- `camera_->request_image(camera::IDLE);`   // in update(); IDLE = "send to app"
- in `on_camera_image`: gate on `pending_` **and**
  `image->was_requested_by(camera::IDLE)` (you also receive web/api frames),
  then read `image->get_data_buffer()` / `image->get_data_length()`.
- POST with `esp_http_client` (`esp_http_client_init/set_header/
  set_post_field/perform`), `config.crt_bundle_attach = esp_crt_bundle_attach`
  for HTTPS. Read a response header in the `HTTP_EVENT_ON_HEADER` handler (pass
  `this` via `config.user_data`) to let the server retune the interval:
  `stop_poller(); set_update_interval(ms); start_poller();`.

Enum values: `camera::CameraRequester { IDLE, API_REQUESTER, WEB_REQUESTER }`.
Image class is `camera::CameraImage` (base); the ESP32 impl is
`esp32_camera::ESP32CameraImage`. (Older code used `esp32_camera::CameraImage`
and `esp32_camera::IDLE` — both moved to the `camera::` namespace.)

Python codegen (`__init__.py`): reference the camera with
`cv.use_id(esp32_camera.ESP32Camera)` and `await cg.get_variable(...)`;
`.extend(cv.polling_component_schema("60s"))`.
