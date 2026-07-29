# Dependency checks for skill scripts. Source, don't run.
#
#   require_tool NAME [HINT...]   exit 127 with install hints when NAME is
#                                 not on PATH
#
# The convention, so a missing dependency is never a mystery: say what is
# missing, then give copy-pasteable ways to install it across the package
# managers a reader might have. Never silently fall back to another way of
# running the tool — a fallback turns a missing dependency into a slow,
# surprising success that nobody fixes.

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
