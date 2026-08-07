# Response cache for the project-notes gatherers. Source, don't run.
#
# Refreshing a project page usually means running a gatherer several times in
# one session — once to see the state, again after an edit, again for a sibling
# project. Each live run is a fetch plus a fistful of forge API calls, so the
# second and third runs pay full price for output that has not changed. An
# entry keyed on the script and its arguments makes a repeat call free, and an
# explicit --refresh makes "I just opened a PR, look again" unambiguous.
#
#   cache_set_ttl MIN       handle --max-age MIN; rejects a non-number
#   cache_file NAME ARG…    path of the entry for this script + arguments
#   degraded MESSAGE        print a row that marks the run uncacheable
#   cache_run FILE CMD…     replay a fresh entry, else run CMD and store it
#
# Callers add two cases to their own flag loop:
#   --refresh | --no-cache) CACHE_REFRESH=1; shift ;;
#   --max-age) cache_set_ttl "${2:-}"; shift 2 || exit 1 ;;
#
# Environment:
#   PROJECT_NOTES_CACHE_TTL   minutes an entry stays fresh (default 30; 0
#                             disables the cache, which is what tests want)
#   PROJECT_NOTES_CACHE_DIR   entry root (default $XDG_CACHE_HOME/project-notes)

CACHE_DIR=${PROJECT_NOTES_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/project-notes}
CACHE_TTL=${PROJECT_NOTES_CACHE_TTL:-30}
CACHE_REFRESH=''

# A missing login, a rate limit, an uninstalled forge CLI: the run rendered
# markdown but not an answer, and storing it would report an empty forge for
# the rest of the window. Gatherers say so with degraded(); grepping their
# prose for "failed" instead would go stale the first time a message is
# reworded — or the first time a PR is titled "handle rate limit".
CACHE_DEGRADED_MARK='- ⚠ '
degraded() { printf '%s%s\n' "$CACHE_DEGRADED_MARK" "$*"; }
cache_storable() { ! grep -qF -- "$CACHE_DEGRADED_MARK" "$1"; }

cache_set_ttl() {
  case "${1:-}" in
    '' | *[!0-9]*)
      echo "error: --max-age wants a whole number of minutes" >&2
      exit 1
      ;;
  esac
  CACHE_TTL=$1
}

# The vault and clone roots are part of the identity: the same slug under a
# different NOTES_DIR is a different project. The readable prefix is for the
# human who lists the cache dir; the checksum is what makes the name unique.
cache_file() {
  local raw sum name
  raw="$*|${NOTES:-}|${REPOS:-}"
  sum=$(printf '%s' "$raw" | cksum)
  sum=${sum%% *}
  name=$(printf '%s' "$*" | tr -c '[:alnum:]._-' '-')
  printf '%s/%s-%s.md\n' "$CACHE_DIR" "${name:0:48}" "$sum"
}

cache_age_min() {
  local mtime now
  mtime=$(stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null) || return 1
  [ -n "$mtime" ] || return 1
  now=$(date +%s)
  echo $(((now - mtime) / 60))
}

cache_run() {
  local file=$1 age tmp status
  shift

  if [ "$CACHE_TTL" -le 0 ]; then
    "$@"
    return $?
  fi

  if [ -z "$CACHE_REFRESH" ] && [ -f "$file" ] &&
    age=$(cache_age_min "$file") && [ "$age" -lt "$CACHE_TTL" ]; then
    printf '> cached %sm ago (max-age %sm) — pass --refresh for live forge state\n\n' \
      "$age" "$CACHE_TTL"
    cat "$file"
    return 0
  fi

  if ! mkdir -p "$CACHE_DIR" 2>/dev/null || ! tmp=$(mktemp "$CACHE_DIR/.tmp.XXXXXX" 2>/dev/null); then
    "$@"
    return $?
  fi
  # Nothing else evicts, so drop entries far past any plausible window.
  find "$CACHE_DIR" -maxdepth 1 -name '*.md' -mmin "+$((CACHE_TTL * 8))" -delete 2>/dev/null

  "$@" | tee "$tmp"
  status=${PIPESTATUS[0]}
  if [ "$status" -eq 0 ] && cache_storable "$tmp"; then
    mv -f "$tmp" "$file"
  else
    rm -f "$tmp"
  fi
  return "$status"
}
