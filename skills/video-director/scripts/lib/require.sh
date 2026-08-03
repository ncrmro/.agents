# shellcheck shell=bash
# Dependency checks for skill scripts. Source, do not run.

require_tool() {
  local tool=$1
  shift
  command -v "$tool" >/dev/null 2>&1 && return 0
  {
    printf '%s: %s is required but is not on PATH.\n' "${0##*/}" "$tool"
    if [ $# -gt 0 ]; then
      printf '\nHINT  install it with one of:\n'
      local hint
      for hint in "$@"; do
        printf '        %s\n' "$hint"
      done
    fi
  } >&2
  exit 127
}
