#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix is required to install playwright MCP" >&2
  exit 1
fi

install_if_missing() {
  local attr="$1"
  local marker="$2"

  if nix profile list | grep -Fq "$marker"; then
    echo "[playwright-mcp] profile already has $marker"
    return
  fi

  echo "[playwright-mcp] installing nixpkgs#$attr into the default Nix profile"
  nix profile add "nixpkgs#$attr"
}

install_if_missing "playwright-mcp" "playwright-mcp"
install_if_missing "playwright-driver.browsers" "playwright-driver.browsers"

mcp_out="$(nix build --no-link --print-out-paths nixpkgs#playwright-mcp)"
browsers_out="$(nix build --no-link --print-out-paths nixpkgs#playwright-driver.browsers)"

if [ -x "$mcp_out/bin/mcp-server-playwright" ]; then
  mcp_exe="$mcp_out/bin/mcp-server-playwright"
elif [ -x "$mcp_out/bin/playwright-mcp" ]; then
  mcp_exe="$mcp_out/bin/playwright-mcp"
else
  echo "error: expected $mcp_out to provide mcp-server-playwright or playwright-mcp" >&2
  exit 1
fi

bin_dir="${HOME}/.local/bin"
wrapper="${bin_dir}/mcp-server-playwright"
mkdir -p "$bin_dir"

cat >"$wrapper" <<EOF
#!/usr/bin/env bash
set -euo pipefail

export PLAYWRIGHT_BROWSERS_PATH="$browsers_out"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1"
export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true"

state_root="\${XDG_STATE_HOME:-\$HOME/.local/state}/playwright-mcp"
mkdir -p "\$state_root/profiles"
export PWMCP_PROFILES_DIR_FOR_TEST="\$state_root/profiles"

exec "$mcp_exe" "\$@"
EOF

chmod +x "$wrapper"

resolved="$(command -v mcp-server-playwright || true)"
if [ "$resolved" != "$wrapper" ]; then
  echo "warning: $wrapper was installed, but PATH resolves mcp-server-playwright to: ${resolved:-<missing>}" >&2
  echo "warning: put $bin_dir before the Nix profile in PATH so mcp.json uses the wrapper" >&2
else
  echo "[playwright-mcp] PATH resolves mcp-server-playwright to $resolved"
fi

mcp-server-playwright --help >/dev/null

echo "[playwright-mcp] ready: chromium MCP server can start from mcp.json"
