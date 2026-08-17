#!/usr/bin/env bash
# Gather open/closed issues, PRs, and milestones for every repo of a project,
# formatted as vault-ready markdown rows. Read-only: touches no repo state and
# never writes to the vault. Run gather.sh --help for usage.
set -uo pipefail

export GH_PAGER=cat PAGER=cat

# shellcheck source=lib/project-page.sh
. "$(dirname "$0")/lib/project-page.sh"
# shellcheck source=lib/cache.sh
. "$(dirname "$0")/lib/cache.sh"

usage() {
  cat <<'EOF'
gather.sh — collect the forge state of a project's repos as markdown rows
for the project-notes skill.

Usage:
  gather.sh SLUG                  repos from wiki/projects/SLUG/README.md frontmatter
  gather.sh --repos O/R[,O/R…]    explicit repo list, no project page needed
  gather.sh SLUG --since DATE     also list items closed since DATE (YYYY-MM-DD)
  gather.sh SLUG --refresh        ignore the cached answer and query the forge
  gather.sh SLUG --max-age MIN    treat a cached answer older than MIN as stale
  gather.sh -h | --help

Run the --since form alone when refreshing a page: its output is a superset of
the bare form's.

Caching: an answer is reused for 30 minutes per (slug, flags), so calling this
again while writing the page costs nothing. A replayed answer says so on its
first line. Pass --refresh after you change forge state — opening a PR, closing
an issue — or when the age on that line is older than the question deserves.
Failed and degraded runs are never cached.

Environment:
  NOTES_DIR                 vault root (default ~/notes)
  REPOS_DIR                 clone root (default ~/repos)
  PROJECT_NOTES_CACHE_TTL   default max-age in minutes (0 disables the cache)
  PROJECT_NOTES_CACHE_DIR   cache root (default $XDG_CACHE_HOME/project-notes)

Host resolution: the origin remote of $REPOS_DIR/OWNER/REPO decides the forge;
github.com uses gh, every other host uses tea (Forgejo/Gitea) with its default
login. With no clone the repo is assumed to be on github.com and a warning goes
to stderr — heed it, because a Forgejo repo queried through gh reports "- none"
rather than failing.

Output sections, per repo:
  open PRs · open issues · milestones (all states) · closed since DATE

Rows use the vault link convention, [PR #4](url): Title — ready to paste into
a project page's Recently closed section. An Open Tasks row needs a checkbox,
a description, and #<project> #task tags added; see the skill. An empty section
prints "- none"; a section that could not be queried prints a "- ⚠ …" row and
keeps the run out of the cache.
EOF
}

slug='' repolist='' since=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    --refresh | --no-cache) CACHE_REFRESH=1; shift; continue ;;
    --max-age) cache_set_ttl "${2:-}"; shift 2 || exit 1; continue ;;
    --repos) repolist=${2:-}; shift 2 || exit 1 ;;
    --since) since=${2:-}; shift 2 || exit 1 ;;
    -*) echo "error: unknown flag '$1'" >&2; usage >&2; exit 1 ;;
    *) slug=$1; shift ;;
  esac
done

main() {
  repos=()
  if [ -n "$repolist" ]; then
    IFS=', ' read -r -a repos <<<"$repolist"
  elif [ -n "$slug" ]; then
    page=$(project_page "$slug") || exit 1
    while IFS= read -r line; do repos+=("$line"); done < <(page_repos "$page")
    echo "# project-notes: $slug ($page)"
    echo
  else
    echo "error: give a project SLUG or --repos OWNER/REPO" >&2
    usage >&2
    exit 1
  fi

  if [ ${#repos[@]} -eq 0 ]; then
    echo "- no repos found — add a \`repos:\` list to the page frontmatter or pass --repos"
    exit 0
  fi

  # section TITLE COMMAND… — heading plus rows, "- none" when the query
  # answered with nothing, or a degraded row when it could not answer at all.
  #
  # These two must never render the same. A forge that replies 503 produces an
  # empty list, and "- none" reads as "nothing is open" — so refreshing a page's
  # Open Tasks wholesale from that output deletes every open row, with no error
  # anywhere to notice. Piping straight to grep also hid the status, since a
  # pipeline reports grep's exit code and not the query's.
  section() {
    local title=$1; shift
    local out status errfile
    errfile=$(mktemp)
    out=$("$@" 2>"$errfile"); status=$?
    echo
    echo "### $title"
    if [ "$status" -ne 0 ]; then
      degraded "$title unavailable — $(head -1 "$errfile" | cut -c1-200)"
    elif printf '%s' "$out" | grep -q .; then
      printf '%s\n' "$out" | grep .
    else
      echo "- none"
    fi
    rm -f "$errfile"
  }

  gh_prs() {
    gh pr list -R "$1" --limit 200 --json number,title,url,isDraft --template \
      '{{range .}}- [PR #{{.number}}]({{.url}}): {{.title}}{{if .isDraft}} · draft{{end}}{{"\n"}}{{end}}'
  }
  gh_issues() {
    gh issue list -R "$1" --limit 200 --json number,title,url,milestone --template \
      '{{range .}}- [Issue #{{.number}}]({{.url}}): {{.title}}{{if .milestone}} · milestone {{.milestone.title}}{{end}}{{"\n"}}{{end}}'
  }
  gh_milestones() {
    gh api "repos/$1/milestones?state=all" --jq \
      '.[] | "- \(.title) [\(.state)] — \(.open_issues) open / \(.closed_issues) closed\(if .due_on then " · due \(.due_on[0:10])" else "" end)"'
  }
  # One search covers issues and PRs; .pull_request tells them apart, and closed
  # unmerged PRs are included (a --merged search would silently drop them).
  gh_closed() {
    gh api -X GET search/issues -f q="repo:$1 is:closed closed:>=$2" -f per_page=100 --jq \
      '.items[] | (if .pull_request then "- [PR #\(.number)](\(.html_url))" else "- [Issue #\(.number)](\(.html_url))" end)
       + ": \(.title) · closed \(.closed_at[0:10])"'
  }

  # Forgejo returns issues and PRs from one endpoint; .pull_request splits them.
  tea_filter() {
    printf '%s' "$items" | jq -r "$@"
  }
  tea_milestones() {
    tea api --repo "$1" "/repos/{owner}/{repo}/milestones?state=all" |
      jq -r '.[] | "- \(.title) [\(.state)] — \(.open_issues) open / \(.closed_issues) closed"'
  }

  for repo in "${repos[@]}"; do
    [ -n "$repo" ] || continue
    host=$(forge_host "$repo")
    echo "## $host/$repo"

    if [ "$host" = github.com ]; then
      if ! command -v gh >/dev/null 2>&1; then
        degraded "gh not installed; skipping $repo"
        echo
        continue
      fi
      section "open PRs" gh_prs "$repo"
      section "open issues" gh_issues "$repo"
      section "milestones" gh_milestones "$repo"
      [ -n "$since" ] && section "closed since $since" gh_closed "$repo" "$since"
    else
      if ! command -v tea >/dev/null 2>&1; then
        degraded "tea not installed; skipping $repo"
        echo
        continue
      fi
      base="https://$host/$repo"
      # One fetch per repo; every section below filters this locally.
      if ! items=$(tea api --repo "$repo" "/repos/{owner}/{repo}/issues?state=all&limit=500" 2>/dev/null); then
        degraded "tea request failed — is a login configured for $host? (tea login list)"
        echo
        continue
      fi
      section "open PRs" tea_filter --arg b "$base" '
        map(select(.pull_request != null and .state == "open")) | .[]
        | "- [PR #\(.number)](\($b)/pulls/\(.number)): \(.title)"'
      section "open issues" tea_filter --arg b "$base" '
        map(select(.pull_request == null and .state == "open")) | .[]
        | "- [Issue #\(.number)](\($b)/issues/\(.number)): \(.title)"
          + (if .milestone then " · milestone \(.milestone.title)" else "" end)'
      section "milestones" tea_milestones "$repo"
      [ -n "$since" ] && section "closed since $since" tea_filter --arg b "$base" --arg s "$since" '
        map(select(.state == "closed" and (.closed_at // "") >= $s)) | .[]
        | (if .pull_request then "- [PR #\(.number)](\($b)/pulls/\(.number))" else "- [Issue #\(.number)](\($b)/issues/\(.number))" end)
          + ": \(.title) · closed \(.closed_at[0:10])"'
    fi
    echo
  done
}

cache_run "$(cache_file gather "$slug" "$repolist" "$since")" main || exit $?
