# Firmware devenv (v2) — copyable template

A standalone devenv for an ESPHome firmware directory. ESPHome comes from a
**pip venv**, not nixpkgs, because the nixpkgs `esphome` can't drive the
pioarduino ESP-IDF build (`idf_tools.py … No module named 'platformio'`).

## `devenv.yaml`

```yaml
# yaml-language-server: $schema=https://devenv.sh/devenv.schema.json
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
```

## `.envrc`

```bash
#!/usr/bin/env bash
eval "$(devenv direnvrc)"
use devenv
```

## `devenv.nix`

```nix
{ pkgs, ... }:

{
  # ESPHome from a pip venv (NOT nixpkgs esphome — it can't build ESP-IDF here).
  # pip esphome manages its own PlatformIO/ESP-IDF toolchain in ~/.platformio.
  languages.python = {
    enable = true;
    venv = {
      enable = true;
      requirements = ''
        esphome
        esptool
        requests
      '';
    };
  };

  packages = with pkgs; [ git ];        # ESP-IDF cmake shells out to git

  env.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";  # HTTPS on NixOS
  env.PORT = "/dev/ttyACM0";
  env.GIT_DISCOVERY_ACROSS_FILESYSTEM = "1";  # git worktrees: .git is a file

  # Wi-Fi/token live in a gitignored .env; bridge to ESPHome secrets.yaml.
  dotenv.enable = true;

  scripts.fw-secrets.exec = ''
    cd "$DEVENV_ROOT"
    if [ -n "''${WIFI_SSID:-}" ]; then
      umask 077
      cat > secrets.yaml <<EOF
wifi_ssid: "$WIFI_SSID"
wifi_password: "''${WIFI_PASSWORD:-}"
api_token: "''${API_TOKEN:-}"
EOF
      echo "secrets.yaml written from .env"
    fi
  '';

  scripts.fw-compile.exec = ''cd "$DEVENV_ROOT" && fw-secrets && esphome compile FIRMWARE.yaml'';
  scripts.fw-flash.exec   = ''cd "$DEVENV_ROOT"; fw-secrets; esphome run FIRMWARE.yaml --device "''${1:-$PORT}"'';
  scripts.fw-logs.exec    = ''cd "$DEVENV_ROOT" && esphome logs FIRMWARE.yaml --device "''${1:-$PORT}"'';
  scripts.fw-clean.exec   = ''cd "$DEVENV_ROOT" && esphome clean FIRMWARE.yaml'';
}
```

Replace `FIRMWARE.yaml` with the actual file name.

## `.gitignore`

```
secrets.yaml
.env
.esphome/
.devenv/
.direnv/
devenv.lock
*.bin
build/
__pycache__/
*.pyc
```

## `.env.example` (commit this; `.env` is gitignored)

```
WIFI_SSID=
WIFI_PASSWORD=
# any device/API token the firmware needs, e.g.:
API_TOKEN=
```

## Notes

- devenv reloads config (incl. dotenv) on `devenv shell`; after editing `.env`,
  a fresh `devenv shell -- fw-flash` picks it up. Verify with
  `devenv shell -- bash -c 'echo ${#WIFI_SSID}'` (length only).
- The pip venv lands at `.devenv/state/venv`; `which esphome` should point there.
- ESP-IDF `sdkconfig`/build cache is under `.esphome/build/<name>/` — gitignored;
  `esphome clean` (or `fw-clean`) drops it.
