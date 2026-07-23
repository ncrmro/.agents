#!/usr/bin/env bash
# Gather the raw state needed to draw a project-planning graph.
# Read-only; prints markdown to stdout. Each section maps onto graph rows:
#   last release  -> bottom ◇ row          shipped commits -> ● rows
#   open PRs      -> ◉ lanes (head → base; base != main ⇒ stacked)
#   milestones    -> boundary rows          open issues     -> ○ candidates
# Sections degrade gracefully when a tool (gh/tea) or convention is absent.
set -uo pipefail

# Plain stdout, never a pager — git/gh/tea all page on a tty otherwise.
export GIT_PAGER=cat GH_PAGER=cat PAGER=cat

main=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
main=${main:-main}
git fetch --quiet --tags 2>/dev/null || true
last_tag=$(git tag --list 'v*' --sort=-v:refname | head -1)
range=${last_tag:+$last_tag..}HEAD

echo "## git"
echo "- default branch: $main @ $(git log -1 --format='%h %s' "$main" 2>/dev/null || git log -1 --format='%h %s')"
echo "- last release (bottom ◇): ${last_tag:-none} $(git log -1 --format='— %as' "$last_tag" 2>/dev/null)"

echo
echo "## shipped since ${last_tag:-the beginning} (● rows, newest first)"
git log --format='- ● %h %s' "$range" -- 2>/dev/null || echo "- none"

# Predicted next ◇ from conventional commits (verify against release-please
# config: bump-minor-pre-major / bump-patch-for-minor-pre-major change this).
if [ -n "$last_tag" ]; then
  if git log --format='%s%n%b' "$range" | grep -qE '^[a-z]+(\(.+\))?!:|^BREAKING CHANGE'; then bump=major
  elif git log --format='%s' "$range" | grep -qE '^feat(\(.+\))?:'; then bump=minor
  else bump=patch; fi
  IFS=. read -r maj min pat <<<"${last_tag#v}"
  case $bump in
    major) next="$((maj + 1)).0.0" ;;
    minor) next="$maj.$((min + 1)).0" ;;
    patch) next="$maj.$min.$((pat + 1))" ;;
  esac
  echo
  echo "- predicted next ◇: v$next (next) — $bump bump from commits so far"
fi

echo
echo "## milestone dirs (docs/milestones/M<n>-<slug>/ — n=N means draft/RFC)"
found=
for f in docs/milestones/M*/readme.md docs/milestones/M*/README.md; do
  [ -f "$f" ] || continue
  found=1
  dir=$(basename "$(dirname "$f")")
  n=${dir#M}; n=${n%%-*}
  case "$n" in N | n) state="draft (RFC — not yet on the graph)" ;; *) state="active" ;; esac
  title=$(grep -m1 '^# ' "$f" | sed 's/^# *//')
  echo "- $dir · $state · ${title:-untitled} · $f"
done
[ -n "$found" ] || echo "- none found"

echo
echo "## open PRs (◉ lanes; base != $main ⇒ stacked, one lane deeper)"
if command -v gh >/dev/null 2>&1 && gh repo view >/dev/null 2>&1; then
  gh pr list --json number,title,headRefName,baseRefName,isDraft --template \
    '{{range .}}- ◉ PR #{{.number}}  {{.headRefName}} → {{.baseRefName}}{{if .isDraft}} · draft{{end}} · {{.title}}{{"\n"}}{{end}}'
  echo
  echo "## pending release PR (an open one means the next ◇ is staged)"
  gh pr list --search 'release in:title' --json number,title --template \
    '{{range .}}- PR #{{.number}} {{.title}}{{"\n"}}{{end}}'
elif command -v tea >/dev/null 2>&1; then # Forgejo / Gitea
  tea pr list --output simple 2>/dev/null || echo "- tea present but not logged in; skipped"
else
  echo "- no forge CLI (gh or tea); list PRs manually"
fi

echo
echo "## forge milestones and their open issues (○ candidates)"
if command -v gh >/dev/null 2>&1 && gh repo view >/dev/null 2>&1; then
  gh api 'repos/{owner}/{repo}/milestones?state=all' --jq \
    '.[] | "- \(.title) [\(.state)] — \(.open_issues) open / \(.closed_issues) closed"' 2>/dev/null
  gh api 'repos/{owner}/{repo}/milestones?state=open' --jq '.[].title' 2>/dev/null |
    while IFS= read -r m; do
      echo "  ### $m"
      gh issue list --milestone "$m" --json number,title --template \
        '{{range .}}  - ○ #{{.number}} {{.title}}{{"\n"}}{{end}}'
    done
elif command -v tea >/dev/null 2>&1; then
  tea milestones list --output simple 2>/dev/null || echo "- tea present but not logged in; skipped"
else
  echo "- no forge CLI; read docs/milestones/ readmes instead"
fi
