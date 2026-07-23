#!/usr/bin/env bash
# Gather the raw state needed to draw a project-planning graph.
# Makes no repo changes beyond a rate-limited `git fetch --tags`.
# Prints markdown to stdout. Run state.sh --help for usage.
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
                            ssh://git@forge.example.com/owner/repo
                            git@forge.example.com:owner/repo.git
  state.sh TARGET TARGET…   several repos back to back — for projects that
                            span repos in an org, one report per repo
  state.sh -h | --help      show this help

Output sections map onto graph rows:
  last release   -> bottom ◇ row        shipped commits -> ● rows
  open PRs       -> ◉ lanes (head → base; base != main ⇒ stacked)
  milestone dirs -> boundary rows        open issues     -> ○ candidates

github.com targets use gh; other hosts use tea (Forgejo/Gitea — tea uses
its default login, so make sure it matches the target host). Local-only
sections (git log, tags, docs/milestones/) need a checkout: the current
directory when it is a clone of the target, else the conventional
~/repos/OWNER/REPO location; they are skipped when neither exists. Every
section degrades gracefully when a tool or convention is absent.
EOF
}

# Several targets: one isolated run per repo, back to back.
if [ $# -gt 1 ]; then
  rc=0
  for t in "$@"; do
    "$0" "$t" || rc=$?
    echo
  done
  exit "$rc"
fi

# Parse OWNER/REPO or a forge URL/remote into $host and $repo; 1 on no match.
parse_target() {
  local t=${1%.git}
  case "$t" in
    http://* | https://*) t=${t#*://}; host=${t%%/*}; repo=${t#*/} ;;
    ssh://*) t=${t#ssh://}; t=${t#*@}; host=${t%%/*}; host=${host%%:*}; repo=${t#*/} ;;
    git@*) t=${t#git@}; host=${t%%:*}; repo=${t#*:} ;;
    */*) host=github.com; repo=$t ;;
    *) return 1 ;;
  esac
  repo=$(printf '%s\n' "$repo" | cut -d/ -f1,2)
}

host="" repo=""
case "${1:-}" in
  -h | --help) usage; exit 0 ;;
  "") ;;
  *)
    if ! parse_target "$1"; then
      echo "error: unrecognized target '$1' (want OWNER/REPO or a forge URL)" >&2
      echo >&2
      usage >&2
      exit 1
    fi
    ;;
esac

# Local git sections need a checkout of the target: the cwd if it is a clone,
# else the conventional ~/repos/<owner>/<repo> location.
local_ok='' checkout=''
if git rev-parse --git-dir >/dev/null 2>&1; then
  origin=$(git remote get-url origin 2>/dev/null || true)
  if [ -z "$repo" ]; then
    local_ok=1
    # Derive host/repo from origin so the forge sections work for bare runs
    # (including non-github origins, which route to tea).
    case "$origin" in
      http://* | https://* | ssh://* | git@*) parse_target "$origin" || true ;;
    esac
  else
    # Anchored: the origin path must end in exactly owner/repo(.git), so a
    # clone of owner/repo-extra is never mistaken for owner/repo.
    case "$origin" in
      *[:/]"$repo" | *[:/]"$repo".git) local_ok=1 ;;
    esac
  fi
fi
if [ -z "$local_ok" ] && [ -n "$repo" ] &&
  git -C "$HOME/repos/$repo" rev-parse --git-dir >/dev/null 2>&1; then
  cd "$HOME/repos/$repo" || exit 1
  local_ok=1 checkout="$HOME/repos/$repo"
fi

# Forge CLI: gh for github.com, tea (Forgejo/Gitea) for everything else.
forge=
gh_r=() tea_r=()
if [ -z "$host" ] || [ "$host" = github.com ]; then
  if command -v gh >/dev/null 2>&1; then
    if [ -n "$repo" ]; then
      forge=gh; gh_r=(-R "$repo")
    elif repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) &&
      [ -n "$repo" ]; then
      forge=gh
    fi
  fi
elif command -v tea >/dev/null 2>&1; then
  forge=tea; tea_r=(--repo "$repo")
fi

[ -n "$repo" ] && echo "# state: ${host:-github.com}/$repo" && echo

if [ -n "$local_ok" ]; then
  main=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
  main=${main:-main}
  # One tag fetch per 10 minutes — repeated runs skip the network round-trip.
  gitdir=$(git rev-parse --git-dir)
  if [ -z "$(find "$gitdir/FETCH_HEAD" -mmin -10 2>/dev/null)" ]; then
    git fetch --quiet --tags 2>/dev/null || true
  fi
  last_tag=$(git tag --list 'v*' --sort=-v:refname | head -1)
  # ● rows are commits on the default branch, not the cwd branch — a feature
  # worktree must not report its unmerged commits as shipped.
  tip=$(git rev-parse --verify -q "origin/$main" 2>/dev/null ||
    git rev-parse --verify -q "$main" 2>/dev/null || echo HEAD)
  range=${last_tag:+$last_tag..}$tip

  echo "## git"
  [ -n "$checkout" ] && echo "- using checkout: $checkout"
  echo "- default branch: $main @ $(git log -1 --format='%h %s' "$tip" 2>/dev/null)"
  echo "- last release (bottom ◇): ${last_tag:-none (v* tags only)} $(git log -1 --format='— %as' "$last_tag" 2>/dev/null)"

  echo
  echo "## shipped since ${last_tag:-the beginning} (● rows, newest first)"
  shipped=$(git log --format='- ● %h %s' "$range" -- 2>/dev/null)
  printf '%s\n' "${shipped:-- none}"

  # Predicted next ◇ from conventional commits since the last tag.
  if [ -n "$last_tag" ]; then
    if git log --format='%s%n%b' "$range" | grep -qE '^[a-z]+(\(.+\))?!:|^BREAKING CHANGE'; then bump="major"
    elif git log --format='%s' "$range" | grep -qE '^feat(\(.+\))?:'; then bump="minor"
    else bump="patch"; fi
    core=${last_tag#v}
    core=${core%%[-+]*} # strip prerelease/build suffix (v1.3.0-rc.1 → 1.3.0)
    IFS=. read -r maj min pat <<<"$core"
    maj=${maj:-0} min=${min:-0} pat=${pat:-0}
    echo
    case "$maj$min$pat" in
      *[!0-9]*)
        echo "- predicted next ◇: unknown — could not parse tag '$last_tag'"
        ;;
      *)
        case $bump in
          major) next="$((maj + 1)).0.0" ;;
          minor) next="$maj.$((min + 1)).0" ;;
          patch) next="$maj.$min.$((pat + 1))" ;;
        esac
        echo "- predicted next ◇: v$next (next) — $bump bump by default rules (pre-1.0 release-please configs may differ)"
        ;;
    esac
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
  echo "- skipped: neither the current directory nor ~/repos/${repo:-<owner>/<repo>}"
  echo "  is a clone of the target; clone it to get ● rows, the bottom ◇, the"
  echo "  predicted version, and docs/milestones/ dirs"
fi

echo
echo "## open PRs (◉ lanes; base != main ⇒ stacked, one lane deeper)"
case $forge in
  gh)
    if prs=$(gh pr list ${gh_r[@]+"${gh_r[@]}"} --json number,title,headRefName,baseRefName,isDraft --template \
      '{{range .}}- ◉ PR #{{.number}}  {{.headRefName}} → {{.baseRefName}}{{if .isDraft}} · draft{{end}} · {{.title}}{{"\n"}}{{end}}'); then
      printf '%s\n' "${prs:-- none}"
      echo
      echo "## pending release PR (an open one means the next ◇ is staged)"
      # Anchor on release-please's own signals, not the bare word "release".
      printf '%s\n' "$prs" | grep -E 'release-please--|chore(\([^)]*\))?: release [0-9]' || true
    else
      echo "- gh pr list failed (auth, network, rate limit?); PR sections skipped"
    fi
    ;;
  tea)
    echo "- via tea (default login — ensure it matches $host; no base-branch info, so stacks are not detectable)"
    tea pr list ${tea_r[@]+"${tea_r[@]}"} --output simple 2>/dev/null ||
      echo "- tea failed — is a login configured for $host? (tea login add)"
    ;;
  *)
    echo "- no forge access (gh for github.com, tea for Forgejo/Gitea); list PRs manually"
    ;;
esac

echo
echo "## forge milestones and their open issues (○ candidates)"
case $forge in
  gh)
    gh api "repos/$repo/milestones?state=all" --jq \
      '.[] | "- \(.title) [\(.state)] — \(.open_issues) open / \(.closed_issues) closed"' 2>/dev/null
    # One call for all open issues, grouped by milestone locally.
    gh issue list ${gh_r[@]+"${gh_r[@]}"} --limit 500 --json number,title,milestone --jq \
      'map(select(.milestone != null)) | group_by(.milestone.title) | .[]
       | "  ### \(.[0].milestone.title)", (.[] | "  - ○ #\(.number) \(.title)")' 2>/dev/null
    ;;
  tea)
    tea milestones list ${tea_r[@]+"${tea_r[@]}"} --output simple 2>/dev/null ||
      echo "- tea failed — is a login configured for $host? (tea login add)"
    ;;
  *)
    echo "- no forge access; read docs/milestones/ readmes instead"
    ;;
esac
