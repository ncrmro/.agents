#!/usr/bin/env bash
# Gather a project page's cross-repo state before editing project notes.
# Derived from project-planning/scripts/state.sh, but project-notes-owned:
# it reads repos from wiki/projects/<slug>/README.md and prints note-refresh
# evidence for multi-repo work. Read-only except for a rate-limited git fetch
# of tags/remote refs in local checkouts.
set -uo pipefail

export GIT_PAGER=cat GH_PAGER=cat PAGER=cat

# shellcheck source=lib/project-page.sh
. "$(dirname "$0")/lib/project-page.sh"

usage() {
  cat <<'EOF'
state.sh — collect graph-ready and note-refresh state for a project's repos.

Usage:
  state.sh SLUG                  repos from wiki/projects/SLUG/README.md frontmatter
  state.sh --repos O/R[,O/R…]    explicit repo list, no project page needed
  state.sh --target OWNER/REPO   one explicit forge repo
  state.sh --target URL          one explicit forge URL/remote
  state.sh --mine                limit GitHub PR/issue rows to involves:@me
  state.sh --all                 do not auto-scope contributor-owned projects
  state.sh --search QUERY        extra GitHub PR/issue search qualifier
  state.sh -h | --help

Use this before hand-editing a project page when work spans repos or when a
request says “find/document what is happening”. It complements gather.sh:

  state.sh   -> graph-ready current state: shipped commits, open PR lanes,
                release prediction, milestone dirs, open milestone issues
  gather.sh  -> vault-ready forge rows: open PRs/issues/milestones and
                closed-since rows for Open Tasks / Recently closed
  harvest.sh -> repo knowledge docs that may need vault notes

Output sections map onto project-planning glyphs while staying read-only for
project-notes refreshes:
  last release   -> bottom ◇ row        shipped commits -> ● rows
  open PRs       -> ◉ lanes             open issues     -> ○ candidates
  milestone dirs -> milestone group evidence

Host resolution: github.com uses gh; every other forge uses tea. Local-only
sections use the current checkout when it matches, a conventional $REPOS_DIR
checkout, or a bounded search under $REPOS_DIR for a clone whose origin matches
the target. Missing local/forge access degrades loudly rather than inventing
state. Pages with `ownership: contributor` are scoped to `involves:@me` by
default; pass `--all` only when the user asks for org-wide activity.
EOF
}

parse_target() {
  local t=${1%.git}
  host='' repo=''
  case "$t" in
    http://* | https://*) t=${t#*://}; host=${t%%/*}; repo=${t#*/} ;;
    ssh://*) t=${t#ssh://}; t=${t#*@}; host=${t%%/*}; host=${host%%:*}; repo=${t#*/} ;;
    git@*) t=${t#git@}; host=${t%%:*}; repo=${t#*:} ;;
    */*) host=github.com; repo=$t ;;
    *) return 1 ;;
  esac
  repo=$(printf '%s\n' "$repo" | cut -d/ -f1,2)
  [ -n "$repo" ] && [ "$repo" != "$host" ]
}

origin_matches_repo() {
  local dir=$1 want=$2 origin
  origin=$(git -C "$dir" remote get-url origin 2>/dev/null || true)
  [ -n "$origin" ] || return 1
  case "$origin" in
    *[:/]"$want" | *[:/]"$want".git) return 0 ;;
  esac
  return 1
}

find_checkout() {
  local want=$1 owner name lower_owner candidate
  owner=${want%%/*}; name=${want#*/}; lower_owner=$(printf '%s' "$owner" | tr '[:upper:]' '[:lower:]')

  if git rev-parse --git-dir >/dev/null 2>&1 && origin_matches_repo . "$want"; then
    pwd
    return 0
  fi

  for candidate in \
    "$REPOS/$want" \
    "$REPOS/$owner/$name/main" \
    "$REPOS/$owner/$name" \
    "$REPOS/$lower_owner/$name/main" \
    "$REPOS/$lower_owner/$name"; do
    if git -C "$candidate" rev-parse --git-dir >/dev/null 2>&1 && origin_matches_repo "$candidate" "$want"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  # Last resort for org-level workspaces whose directory layout is documented in
  # ~/notes/AGENTS.md but not mechanically parseable. Prune dependency/build
  # trees; stop at the first clone whose origin exactly matches OWNER/REPO.
  if [ -d "$REPOS" ]; then
    while IFS= read -r candidate; do
      if git -C "$candidate" rev-parse --git-dir >/dev/null 2>&1 && origin_matches_repo "$candidate" "$want"; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done < <(find "$REPOS" \
      \( -name .git -o -name node_modules -o -name .direnv -o -name .devenv -o -name target -o -name dist \) -prune \
      -o -type d -name "$name" -print 2>/dev/null | head -200)
  fi

  return 1
}

page_ownership() {
  awk '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm && $0 == "---" { exit }
    fm && /^ownership:[[:space:]]*/ { sub(/^ownership:[[:space:]]*/, ""); gsub(/^['"'"']|['"'"']$/, ""); print; exit }
  ' "$1"
}

gh_json_template() {
  local repo=$1 search=${2:-}
  local args=(-R "$repo" --limit 200)
  [ -n "$search" ] && args+=(--search "$search")
  gh pr list "${args[@]}" --json number,title,url,headRefName,baseRefName,isDraft --template \
    '{{range .}}- ◉ [PR #{{.number}}]({{.url}})  {{.headRefName}} → {{.baseRefName}}{{if .isDraft}} · draft{{end}} · {{.title}}{{"\n"}}{{end}}'
}

repos=() slug='' repolist='' target='' mine='' all='' extra_search=''
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage; exit 0 ;;
    --repos) repolist=${2:-}; shift 2 || exit 1 ;;
    --target) target=${2:-}; shift 2 || exit 1 ;;
    --mine) mine=1; shift ;;
    --all) all=1; shift ;;
    --search) extra_search=${2:-}; shift 2 || exit 1 ;;
    -*) echo "error: unknown flag '$1'" >&2; usage >&2; exit 1 ;;
    *) slug=$1; shift ;;
  esac
done

if [ -n "$target" ]; then
  if ! parse_target "$target"; then
    echo "error: unrecognized target '$target' (want OWNER/REPO or URL)" >&2
    exit 1
  fi
  repos=("$repo")
elif [ -n "$repolist" ]; then
  IFS=', ' read -r -a repos <<<"$repolist"
elif [ -n "$slug" ]; then
  page=$(project_page "$slug") || exit 1
  while IFS= read -r line; do repos+=("$line"); done < <(page_repos "$page")
  if [ -z "$all" ] && [ "$(page_ownership "$page")" = contributor ]; then
    mine=1
  fi
  echo "# project-notes state: $slug ($page)"
  echo
else
  echo "error: give a project SLUG, --repos OWNER/REPO, or --target OWNER/REPO" >&2
  usage >&2
  exit 1
fi

if [ ${#repos[@]} -eq 0 ]; then
  echo "- no repos found — add a \`repos:\` list to the page frontmatter or pass --repos"
  exit 0
fi

for repo in "${repos[@]}"; do
  [ -n "$repo" ] || continue
  checkout=$(find_checkout "$repo" || true)
  if [ -n "$checkout" ]; then
    origin=$(git -C "$checkout" remote get-url origin 2>/dev/null || true)
    if parse_target "$origin"; then
      :
    else
      host=github.com
    fi
  else
    host=$(forge_host "$repo" 2>/dev/null || echo github.com)
  fi
  scope_search=${extra_search:-}
  if [ -n "$mine" ]; then
    scope_search="${scope_search:+$scope_search }involves:@me"
  fi

  echo "## $host/$repo"
  [ -n "$scope_search" ] && echo "- forge scope: $scope_search"

  if [ -n "$checkout" ]; then
    (
      cd "$checkout" || exit 1
      main=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
      main=${main:-main}
      gitdir=$(git rev-parse --git-dir)
      if [ -z "$(find "$gitdir/FETCH_HEAD" -mmin -10 2>/dev/null)" ]; then
        git fetch --quiet --tags 2>/dev/null || true
      fi
      last_tag=$(git tag --list 'v*' --sort=-v:refname | head -1)
      tip=$(git rev-parse --verify -q "origin/$main" 2>/dev/null ||
        git rev-parse --verify -q "$main" 2>/dev/null || echo HEAD)
      range=${last_tag:+$last_tag..}$tip

      echo
      echo "### local git evidence"
      echo "- checkout: $checkout"
      echo "- default branch: $main @ $(git log -1 --format='%h %s' "$tip" 2>/dev/null)"
      echo "- last release (bottom ◇): ${last_tag:-none (v* tags only)} $(git log -1 --format='— %as' "$last_tag" 2>/dev/null)"

      echo
      echo "### shipped since ${last_tag:-the beginning} (● rows, newest first)"
      shipped=$(git log --format='- ● %h %s' "$range" -- 2>/dev/null | head -80)
      printf '%s\n' "${shipped:-- none}"

      if [ -n "$last_tag" ]; then
        if git log --format='%s%n%b' "$range" | grep -qE '^[a-z]+(\(.+\))?!:|^BREAKING CHANGE'; then bump=major
        elif git log --format='%s' "$range" | grep -qE '^feat(\(.+\))?:'; then bump=minor
        else bump=patch; fi
        core=${last_tag#v}; core=${core%%[-+]*}
        IFS=. read -r maj min pat <<<"$core"
        maj=${maj:-0}; min=${min:-0}; pat=${pat:-0}
        echo
        case "$maj$min$pat" in
          *[!0-9]*) echo "- predicted next ◇: unknown — could not parse tag '$last_tag'" ;;
          *)
            case $bump in
              major) next="$((maj + 1)).0.0" ;;
              minor) next="$maj.$((min + 1)).0" ;;
              patch) next="$maj.$min.$((pat + 1))" ;;
            esac
            echo "- predicted next ◇: v$next (next) — $bump bump by default rules (check release-please config for pre-1.0 repos)"
            ;;
        esac
      fi

      echo
      echo "### milestone dirs (docs/milestones/M<n>-<slug>/)"
      found=
      for f in docs/milestones/M*/readme.md docs/milestones/M*/README.md; do
        [ -f "$f" ] || continue
        found=1
        dir=$(basename "$(dirname "$f")")
        n=${dir#M}; n=${n%%-*}
        case "$n" in N | n) state="draft (RFC — not yet on the graph)" ;; *) state=active ;; esac
        title=$(grep -m1 '^# ' "$f" | sed 's/^# *//')
        echo "- $dir · $state · ${title:-untitled} · $f"
      done
      [ -n "$found" ] || echo "- none found"
    )
  else
    echo
    echo "### local git evidence"
    echo "- skipped: no checkout found under $REPOS with origin ending in $repo"
  fi

  echo
  echo "### open PRs (◉ lanes; base != main ⇒ stacked)"
  if [ "$host" = github.com ]; then
    if command -v gh >/dev/null 2>&1; then
      if prs=$(gh_json_template "$repo" "$scope_search" 2>/dev/null); then
        printf '%s\n' "${prs:-- none}"
        echo
        echo "### pending release PR"
        printf '%s\n' "$prs" | grep -E 'release-please--|chore(\([^)]*\))?: release [0-9]' || echo "- none"
      else
        echo "- gh pr list failed (auth, network, permissions, or rate limit)"
      fi
    else
      echo "- gh not installed; list GitHub PRs manually"
    fi
  elif command -v tea >/dev/null 2>&1; then
    echo "- via tea (default login — ensure it matches $host; base branch may be absent)"
    tea pr list --repo "$repo" --output simple 2>/dev/null || echo "- tea failed — is a login configured for $host?"
  else
    echo "- tea not installed; list non-GitHub PRs manually"
  fi

  echo
  echo "### forge milestones and open issues (○ candidates)"
  if [ "$host" = github.com ] && command -v gh >/dev/null 2>&1; then
    gh api "repos/$repo/milestones?state=all" --jq \
      '.[] | "- \(.title) [\(.state)] — \(.open_issues) open / \(.closed_issues) closed"' 2>/dev/null || echo "- milestones unavailable"
    issue_args=(-R "$repo" --limit 500)
    [ -n "$scope_search" ] && issue_args+=(--search "$scope_search")
    gh issue list "${issue_args[@]}" --json number,title,url,milestone --jq \
      'map(select(.milestone != null)) | group_by(.milestone.title) | .[]
       | "  #### \(.[0].milestone.title)", (.[] | "  - ○ [Issue #\(.number)](\(.url)): \(.title)")' 2>/dev/null || true
  elif [ "$host" != github.com ] && command -v tea >/dev/null 2>&1; then
    tea milestones list --repo "$repo" --output simple 2>/dev/null || echo "- milestones unavailable"
  else
    echo "- no forge access; use local milestone dirs and gather.sh output"
  fi

  echo
done
