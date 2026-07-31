#!/usr/bin/env bash
# Resolve the speckit feature directory and artifact paths for the current branch.
#
# Replaces upstream spec-kit's create-new-feature.sh / setup-plan.sh /
# setup-tasks.sh / check-prerequisites.sh. Those four scripts exist mostly to
# maintain .specify/feature.json state; here the git branch is the state, so
# one script covers every caller.
set -euo pipefail

. "$(CDPATH="" cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib/require.sh"

usage() {
  cat <<'EOF'
Usage: feature-paths.sh [--json] [--create] [--require ARTIFACT]...

Resolves the feature directory for the current git branch and reports which
speckit artifacts exist in it.

Options:
  --json               Emit resolved paths as JSON (default: human-readable)
  --create             Create the feature directory if it does not exist
  --require ARTIFACT   Exit 1 unless ARTIFACT exists. Repeatable.
                       ARTIFACT is one of: spec, plan, tasks, constitution
  --help, -h           Show this message

Conventions:
  repo root     git rev-parse --show-toplevel
  feature slug  current branch minus its category prefix (feat/x -> x)
  feature dir   <repo-root>/specs/<slug>/
  constitution  <repo-root>/.agents/constitution.md

Examples:
  feature-paths.sh --json
  feature-paths.sh --create --json
  feature-paths.sh --require spec --require plan --json
EOF
}

require_tool git \
  'nix profile install nixpkgs#git' \
  'apt install git' \
  'brew install git'
require_tool jq \
  'nix profile install nixpkgs#jq' \
  'apt install jq' \
  'brew install jq'

JSON_MODE=false
CREATE=false
REQUIRED=()

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON_MODE=true ;;
    --create) CREATE=true ;;
    --require)
      [ $# -ge 2 ] || { echo "ERROR: --require needs an artifact name" >&2; exit 1; }
      case "$2" in
        spec|plan|tasks|constitution) REQUIRED+=("$2") ;;
        *) echo "ERROR: unknown artifact '$2' (want: spec, plan, tasks, constitution)" >&2; exit 1 ;;
      esac
      shift
      ;;
    --help|-h) usage; exit 0 ;;
    *) echo "ERROR: unknown option '$1'. Use --help for usage." >&2; exit 1 ;;
  esac
  shift
done

if ! REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "ERROR: not inside a git repository — speckit resolves the feature from the current branch." >&2
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "HEAD" ]; then
  echo "ERROR: detached HEAD — speckit needs a branch to derive the feature slug from." >&2
  exit 1
fi

# feat/user-auth -> user-auth; a bare branch name is its own slug.
SLUG="${BRANCH##*/}"

case "$BRANCH" in
  main|master|develop)
    echo "ERROR: on '$BRANCH' — cut a feature branch before running speckit." >&2
    echo "HINT  git switch -c feat/<slug>" >&2
    exit 1
    ;;
esac

FEATURE_DIR="$REPO_ROOT/specs/$SLUG"
SPEC="$FEATURE_DIR/spec.md"
PLAN="$FEATURE_DIR/plan.md"
TASKS="$FEATURE_DIR/tasks.md"
CONSTITUTION="$REPO_ROOT/.agents/constitution.md"

if [ "$CREATE" = true ]; then
  mkdir -p "$FEATURE_DIR"
fi

for artifact in ${REQUIRED+"${REQUIRED[@]}"}; do
  case "$artifact" in
    spec) path="$SPEC"; producer="speckit-specify" ;;
    plan) path="$PLAN"; producer="speckit-plan" ;;
    tasks) path="$TASKS"; producer="speckit-tasks" ;;
    constitution) path="$CONSTITUTION"; producer="speckit-constitution" ;;
  esac
  if [ ! -f "$path" ]; then
    echo "ERROR: required artifact missing: $path" >&2
    echo "HINT  run $producer first." >&2
    exit 1
  fi
done

# Everything else in the feature directory, so a caller knows what optional
# design docs (research.md, data-model.md, contracts/, checklists/) exist.
AVAILABLE_DOCS=()
if [ -d "$FEATURE_DIR" ]; then
  for entry in "$FEATURE_DIR"/*; do
    [ -e "$entry" ] || continue   # unmatched glob when the directory is empty
    if [ -d "$entry" ]; then
      AVAILABLE_DOCS+=("${entry##*/}/")
    else
      AVAILABLE_DOCS+=("${entry##*/}")
    fi
  done
fi

exists() { [ -e "$1" ] && echo true || echo false; }

if [ "$JSON_MODE" = true ]; then
  available_json=$(
    if [ ${#AVAILABLE_DOCS[@]} -eq 0 ]; then
      echo '[]'
    else
      printf '%s\n' "${AVAILABLE_DOCS[@]}" | jq -R . | jq -s .
    fi
  )
  jq -n \
    --arg repo_root "$REPO_ROOT" \
    --arg branch "$BRANCH" \
    --arg slug "$SLUG" \
    --arg feature_dir "$FEATURE_DIR" \
    --arg spec "$SPEC" \
    --arg plan "$PLAN" \
    --arg tasks "$TASKS" \
    --arg constitution "$CONSTITUTION" \
    --argjson exists_feature_dir "$(exists "$FEATURE_DIR")" \
    --argjson exists_spec "$(exists "$SPEC")" \
    --argjson exists_plan "$(exists "$PLAN")" \
    --argjson exists_tasks "$(exists "$TASKS")" \
    --argjson exists_constitution "$(exists "$CONSTITUTION")" \
    --argjson available "$available_json" \
    '{
      REPO_ROOT: $repo_root,
      BRANCH: $branch,
      FEATURE_SLUG: $slug,
      FEATURE_DIR: $feature_dir,
      SPEC: $spec,
      PLAN: $plan,
      TASKS: $tasks,
      CONSTITUTION: $constitution,
      EXISTS: {
        feature_dir: $exists_feature_dir,
        spec: $exists_spec,
        plan: $exists_plan,
        tasks: $exists_tasks,
        constitution: $exists_constitution
      },
      AVAILABLE_DOCS: $available
    }'
else
  echo "REPO_ROOT=$REPO_ROOT"
  echo "BRANCH=$BRANCH"
  echo "FEATURE_SLUG=$SLUG"
  echo "FEATURE_DIR=$FEATURE_DIR"
  echo "SPEC=$SPEC"
  echo "PLAN=$PLAN"
  echo "TASKS=$TASKS"
  echo "CONSTITUTION=$CONSTITUTION"
  echo "AVAILABLE_DOCS=${AVAILABLE_DOCS[*]-}"
fi
