# Shared project-page resolution for the project-notes scripts. Source, don't run.
#
#   NOTES / REPOS         vault and clone roots (NOTES_DIR / REPOS_DIR override)
#   project_page SLUG     print the page path, or fail with a message on stderr
#   page_repos PAGE       print the frontmatter `repos:` list, one per line
#   forge_host OWNER/REPO print the forge host from the clone's origin remote;
#                         prints "github.com" and warns on stderr when absent

NOTES=${NOTES_DIR:-$HOME/notes}
REPOS=${REPOS_DIR:-$HOME/repos}

project_page() {
  local slug=$1 page
  # Project directory is canonical; a flat page is the pre-migration layout.
  for page in "$NOTES/wiki/projects/$slug/README.md" "$NOTES/wiki/projects/$slug.md"; do
    [ -f "$page" ] && { printf '%s\n' "$page"; return 0; }
  done
  echo "error: no project page at $NOTES/wiki/projects/$slug/README.md" >&2
  echo "       create it from assets/README.template.md, or pass --repos" >&2
  return 1
}

# Frontmatter only — stop at the closing ---, so a body mention of "repos:"
# cannot inject entries.
page_repos() {
  awk '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm && $0 == "---" { exit }
    fm && /^repos:[[:space:]]*$/ { inlist = 1; next }
    inlist && /^[[:space:]]+-[[:space:]]/ {
      sub(/^[[:space:]]+-[[:space:]]+/, ""); gsub(/^["'\'']|["'\'']$/, ""); print; next
    }
    inlist { inlist = 0 }
  ' "$1"
}

forge_host() {
  local origin
  if ! origin=$(git -C "$REPOS/$1" remote get-url origin 2>/dev/null) || [ -z "$origin" ]; then
    # A Forgejo repo queried through gh returns nothing, which reads as
    # "no open work" on the page.
    echo "warning: no clone at $REPOS/$1 — assuming github.com" >&2
    echo github.com
    return
  fi
  case "$origin" in
    *://* | *@*:*) origin=${origin#*://}; origin=${origin#*@}; echo "${origin%%[:/]*}" ;;
    *) echo github.com ;;
  esac
}
