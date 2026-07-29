#!/usr/bin/env bash
# Compare a project's in-repo wiki/docs notes against the personal vault and
# list the ones the vault does not yet have. Read-only — proposes, never copies.
# Run harvest.sh --help for usage.
set -uo pipefail

# shellcheck source=lib/project-page.sh
. "$(dirname "$0")/lib/project-page.sh"

usage() {
  cat <<'EOF'
harvest.sh — find in-repo knowledge notes that have no counterpart in the
personal vault, for the project-notes skill.

Usage:
  harvest.sh SLUG              repos from wiki/projects/SLUG/README.md frontmatter
  harvest.sh --repos O/R[,O/R…]
  harvest.sh -h | --help

Environment:
  NOTES_DIR   vault root (default ~/notes)
  REPOS_DIR   clone root (default ~/repos)

Scans each clone for note-bearing directories — wiki/, docs/concepts/,
docs/runbooks/, docs/adr/, docs/decisions/ — and reports every markdown file
whose basename has no match anywhere under $NOTES_DIR/wiki/. Existing
counterparts are reported too, with their vault path, so they can be checked
for drift instead of duplicated.

Clones are looked for at $REPOS_DIR/OWNER/REPO. Orgs checked out under a
different shape are reported as "no clone" — check the path before believing
a project has no notes.

Output is a candidate list, not a plan: decide per file whether it is durable
knowledge (→ vault concept/research note), repo-local operational detail
(→ leave it), or an update to a note the vault already has.
EOF
}

repolist='' slug=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    --repos) repolist=${2:-}; shift 2 || exit 1 ;;
    -*) echo "error: unknown flag '$1'" >&2; usage >&2; exit 1 ;;
    *) slug=$1; shift ;;
  esac
done

repos=()
if [ -n "$repolist" ]; then
  IFS=', ' read -r -a repos <<<"$repolist"
elif [ -n "$slug" ]; then
  page=$(project_page "$slug") || exit 1
  while IFS= read -r line; do repos+=("$line"); done < <(page_repos "$page")
else
  echo "error: give a project SLUG or --repos OWNER/REPO" >&2
  usage >&2
  exit 1
fi

[ -d "$NOTES/wiki" ] || { echo "error: no vault wiki at $NOTES/wiki" >&2; exit 1; }

# Index the vault once — the alternative is a full walk per candidate file.
declare -A vault
while IFS= read -r p; do : "${vault[${p##*/}]:=$p}"; done \
  < <(find "$NOTES/wiki" -name '*.md' -type f 2>/dev/null)

for repo in "${repos[@]}"; do
  [ -n "$repo" ] || continue
  root="$REPOS/$repo"
  echo "## $repo"
  if [ ! -d "$root" ]; then
    echo "- no clone at $root — skipped"
    echo
    continue
  fi

  found=''
  for sub in wiki docs/concepts docs/runbooks docs/adr docs/decisions; do
    [ -d "$root/$sub" ] || continue
    while IFS= read -r f; do
      base=${f##*/}
      case "$base" in index.md | log.md | README.md | readme.md) continue ;; esac
      found=1
      rel=${f#"$root"/}
      match=${vault[$base]:-}
      if [ -n "$match" ]; then
        echo "- have: $rel → ${match#"$NOTES"/} (check for drift)"
      else
        title=$(grep -m1 '^# ' "$f" 2>/dev/null | sed 's/^# *//')
        echo "- NEW:  $rel${title:+ — $title}"
      fi
    done < <(find "$root/$sub" -name '*.md' -type f 2>/dev/null | sort)
  done
  [ -n "$found" ] || echo "- no wiki/ or docs/{concepts,runbooks,adr,decisions}/ notes found"
  echo
done
