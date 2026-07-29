#!/usr/bin/env bash
# Gather open/closed issues, PRs, and milestones for every repo of a project,
# formatted as vault-ready markdown rows. Read-only: touches no repo state and
# never writes to the vault. Run gather.sh --help for usage.
set -uo pipefail

export GH_PAGER=cat PAGER=cat

# shellcheck source=lib/project-page.sh
. "$(dirname "$0")/lib/project-page.sh"

usage() {
  cat <<'EOF'
gather.sh — collect the forge state of a project's repos as markdown rows
for the project-notes skill.

Usage:
  gather.sh SLUG                  repos from wiki/projects/SLUG/README.md frontmatter
  gather.sh --repos O/R[,O/R…]    explicit repo list, no project page needed
  gather.sh SLUG --since DATE     also list items closed since DATE (YYYY-MM-DD)
  gather.sh -h | --help

Run the --since form alone when refreshing a page: its output is a superset of
the bare form's.

Environment:
  NOTES_DIR   vault root (default ~/notes)
  REPOS_DIR   clone root (default ~/repos)

Host resolution: the origin remote of $REPOS_DIR/OWNER/REPO decides the forge;
github.com uses gh, every other host uses tea (Forgejo/Gitea) with its default
login. With no clone the repo is assumed to be on github.com and a warning goes
to stderr — heed it, because a Forgejo repo queried through gh reports "- none"
rather than failing.

Output sections, per repo:
  open PRs · open issues · milestones (all states) · closed since DATE

Rows use the vault link convention, [PR #4](url): Title — ready to paste into
a project page's Recently closed section. An Open Tasks row needs a checkbox,
a description, and #<project> #task tags added; see the skill. Missing or
failed sections print "- none".
EOF
}

slug='' repolist='' since=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    --repos) repolist=${2:-}; shift 2 || exit 1 ;;
    --since) since=${2:-}; shift 2 || exit 1 ;;
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

# section TITLE COMMAND… — heading plus rows, or "- none" when empty/failed.
section() {
  local title=$1; shift
  echo
  echo "### $title"
  "$@" 2>/dev/null | grep . || echo "- none"
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
      echo "- gh not installed; skipping $repo"
      echo
      continue
    fi
    section "open PRs" gh_prs "$repo"
    section "open issues" gh_issues "$repo"
    section "milestones" gh_milestones "$repo"
    [ -n "$since" ] && section "closed since $since" gh_closed "$repo" "$since"
  else
    if ! command -v tea >/dev/null 2>&1; then
      echo "- tea not installed; skipping $repo"
      echo
      continue
    fi
    base="https://$host/$repo"
    # One fetch per repo; every section below filters this locally.
    if ! items=$(tea api --repo "$repo" "/repos/{owner}/{repo}/issues?state=all&limit=500" 2>/dev/null); then
      echo "- tea request failed — is a login configured for $host? (tea login list)"
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
