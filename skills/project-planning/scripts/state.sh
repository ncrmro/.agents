#!/usr/bin/env bash
# Gather the raw state needed to draw a project-planning graph.
# Read-only; prints markdown to stdout. Run state.sh --help for usage.
set -uo pipefail

# Plain stdout, never a pager — git/gh/tea all page on a tty otherwise.
export GIT_PAGER=cat GH_PAGER=cat PAGER=cat

usage() {
  cat <<'EOF'
state.sh — gather the current release/milestone state of a repo as
graph-ready rows for the project-planning skill.

Usage:
  state.sh                  target the repo in the current directory
  state.sh OWNER/REPO       target a forge repo (defaults to github.com)
  state.sh URL              full forge URL or remote, e.g.
                            https://github.com/owner/repo
                            https://codeberg.org/owner/repo
                            git@forge.example.com:owner/repo.git
  state.sh -h | --help      show this help

Output sections map onto graph rows:
  last release   -> bottom ◇ row        shipped commits -> ● rows
  open PRs       -> ◉ lanes (head → base; base != main ⇒ stacked)
  milestone dirs -> boundary rows        open issues     -> ○ candidates

github.com targets use gh; other hosts use tea (Forgejo/Gitea — make sure
`tea login` has an account for that host). Local-only sections (git log,
tags, docs/milestones/) need a checkout: they run against the current
directory and are skipped when it isn't a clone of the target. Every
section degrades gracefully when a tool or convention is absent.
EOF
}

host="" repo=""
case "${1:-}" in
  -h | --help) usage; exit 0 ;;
  "") ;;
  *)
    t=${1%.git}
    case "$t" in
      http://* | https://*) t=${t#*://}; host=${t%%/*}; repo=${t#*/} ;;
      git@*) t=${t#git@}; host=${t%%:*}; repo=${t#*:} ;;
      */*) host=github.com; repo=$t ;;
      *) echo "error: unrecognized target '$1' (want OWNER/REPO or a forge URL)" >&2; echo >&2; usage >&2; exit 1 ;;
    esac
    repo=$(printf '%s\n' "$repo" | cut -d/ -f1,2)
    ;;
esac

# Local git sections only make sense when the cwd is (a clone of) the target.
local_ok=
if git rev-parse --git-dir >/dev/null 2>&1; then
  if [ -z "$repo" ]; then
    local_ok=1
  else
    origin=$(git remote get-url origin 2>/dev/null || true)
    case "$origin" in *"$repo"*) local_ok=1 ;; esac
  fi
fi

# Forge CLI: gh for github.com, tea (Forgejo/Gitea) for everything else.
forge=
gh_r=() tea_r=()
if [ -z "$host" ] || [ "$host" = github.com ]; then
  if command -v gh >/dev/null 2>&1; then
    if [ -n "$repo" ]; then
      forge=gh; gh_r=(-R "$repo")
    elif gh repo view >/dev/null 2>&1; then
      forge=gh
      repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)
    fi
  fi
elif command -v tea >/dev/null 2>&1; then
  forge=tea; tea_r=(--repo "$repo")
fi

[ -n "$repo" ] && echo "# state: ${host:-github.com}/$repo" && echo

if [ -n "$local_ok" ]; then
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
    if git log --format='%s%n%b' "$range" | grep -qE '^[a-z]+(\(.+\))?!:|^BREAKING CHANGE'; then bump="major"
    elif git log --format='%s' "$range" | grep -qE '^feat(\(.+\))?:'; then bump="minor"
    else bump="patch"; fi
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
else
  echo "## git"
  echo "- skipped: current directory is not a clone of ${repo:-a git repo};"
  echo "  clone it to get ● rows, the bottom ◇, the predicted version, and"
  echo "  docs/milestones/ dirs"
fi

echo
echo "## open PRs (◉ lanes; base != main ⇒ stacked, one lane deeper)"
case $forge in
  gh)
    gh pr list ${gh_r[@]+"${gh_r[@]}"} --json number,title,headRefName,baseRefName,isDraft --template \
      '{{range .}}- ◉ PR #{{.number}}  {{.headRefName}} → {{.baseRefName}}{{if .isDraft}} · draft{{end}} · {{.title}}{{"\n"}}{{end}}'
    echo
    echo "## pending release PR (an open one means the next ◇ is staged)"
    gh pr list ${gh_r[@]+"${gh_r[@]}"} --search 'release in:title' --json number,title --template \
      '{{range .}}- PR #{{.number}} {{.title}}{{"\n"}}{{end}}'
    ;;
  tea)
    tea pr list ${tea_r[@]+"${tea_r[@]}"} --output simple 2>/dev/null || echo "- tea failed — is a login configured for $host? (tea login add)"
    ;;
  *)
    echo "- no forge access (gh for github.com, tea for Forgejo/Gitea); list PRs manually"
    ;;
esac

echo
echo "## forge milestones and their open issues (○ candidates)"
case $forge in
  gh)
    gh api "repos/${repo:-{owner\}/{repo\}}/milestones?state=all" --jq \
      '.[] | "- \(.title) [\(.state)] — \(.open_issues) open / \(.closed_issues) closed"' 2>/dev/null
    gh api "repos/${repo:-{owner\}/{repo\}}/milestones?state=open" --jq '.[].title' 2>/dev/null |
      while IFS= read -r m; do
        echo "  ### $m"
        gh issue list ${gh_r[@]+"${gh_r[@]}"} --milestone "$m" --json number,title --template \
          '{{range .}}  - ○ #{{.number}} {{.title}}{{"\n"}}{{end}}'
      done
    ;;
  tea)
    tea milestones list ${tea_r[@]+"${tea_r[@]}"} --output simple 2>/dev/null || echo "- tea failed — is a login configured for $host?"
    ;;
  *)
    echo "- no forge access; read docs/milestones/ readmes instead"
    ;;
esac
