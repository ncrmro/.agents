#!/usr/bin/env bash
# Page resolution, frontmatter parsing, and forge routing for the project-notes
# scripts. Uses a temporary vault and clone root; makes no network calls and
# touches nothing outside $TMP.
set -euo pipefail

TEST_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
GATHER=$TEST_DIR/../scripts/gather.sh
HARVEST=$TEST_DIR/../scripts/harvest.sh
TMP=$(mktemp -d "${TMPDIR:-/tmp}/project-notes-test.XXXXXX")
trap 'rm -rf -- "$TMP"' EXIT INT TERM

export NOTES_DIR=$TMP/notes REPOS_DIR=$TMP/repos
mkdir -p "$NOTES_DIR/wiki/projects" "$REPOS_DIR"

fail() {
  printf '%s\n' "FAIL: $1" >&2
  exit 1
}

# A page in the canonical directory layout, plus a body mention of `repos:`
# that must not be parsed as frontmatter.
mkdir -p "$NOTES_DIR/wiki/projects/demo"
cat >"$NOTES_DIR/wiki/projects/demo/README.md" <<'EOF'
---
mission: "demo"
repos:
  - example-org/alpha
  - example-org/beta
tags: [meta]
---

# demo

repos:
  - example-org/should-not-be-parsed
EOF

# A page still in the pre-migration flat layout.
cat >"$NOTES_DIR/wiki/projects/legacy.md" <<'EOF'
---
repos:
  - example-org/gamma
---

# legacy
EOF

# gather.sh reports the resolved page path in its header, so a dry run over a
# repo with no clone exercises resolution + parsing without a forge call.
out=$("$GATHER" demo 2>"$TMP/demo.err") || fail "gather.sh demo exited non-zero"
printf '%s\n' "$out" | grep -F "wiki/projects/demo/README.md" >/dev/null ||
  fail "directory layout not resolved to README.md"
printf '%s\n' "$out" | grep -F 'example-org/alpha' >/dev/null ||
  fail "first frontmatter repo missing"
printf '%s\n' "$out" | grep -F 'example-org/beta' >/dev/null ||
  fail "second frontmatter repo missing"
if printf '%s\n' "$out" | grep -F 'should-not-be-parsed' >/dev/null; then
  fail "body mention of repos: was parsed as frontmatter"
fi

out=$("$GATHER" legacy 2>/dev/null) || fail "gather.sh legacy exited non-zero"
printf '%s\n' "$out" | grep -F "wiki/projects/legacy.md" >/dev/null ||
  fail "flat pre-migration layout not resolved"

# A missing clone must warn on stderr — silently assuming github.com would make
# a Forgejo project's page refresh to an empty task list.
grep -F 'warning: no clone at' "$TMP/demo.err" >/dev/null ||
  fail "missing clone did not warn on stderr"

# A clone whose origin is not github.com must route to tea, not gh.
mkdir -p "$REPOS_DIR/example-org/alpha"
git init -q "$REPOS_DIR/example-org/alpha"
git -C "$REPOS_DIR/example-org/alpha" remote add origin \
  'ssh://forgejo@forge.example.com:2222/example-org/alpha.git'
out=$("$GATHER" demo 2>/dev/null) || fail "gather.sh exited non-zero with a clone present"
printf '%s\n' "$out" | grep -F '## forge.example.com/example-org/alpha' >/dev/null ||
  fail "ssh:// origin with a port did not resolve to its forge host"

# An unknown project fails loudly rather than emitting an empty report.
if "$GATHER" nosuch >"$TMP/nosuch.out" 2>"$TMP/nosuch.err"; then
  fail "expected a missing project page to exit non-zero"
fi
grep -F 'no project page at' "$TMP/nosuch.err" >/dev/null ||
  fail "missing page error not reported on stderr"

# harvest.sh shares the resolver and must classify in-repo notes against the
# vault: a note the vault lacks is NEW, one it already has is have:.
mkdir -p "$REPOS_DIR/example-org/alpha/wiki" "$NOTES_DIR/wiki/concepts"
printf '# Fresh\n' >"$REPOS_DIR/example-org/alpha/wiki/fresh.md"
printf '# Known\n' >"$REPOS_DIR/example-org/alpha/wiki/known.md"
printf '# Known\n' >"$NOTES_DIR/wiki/concepts/known.md"
out=$("$HARVEST" demo 2>/dev/null) || fail "harvest.sh exited non-zero"
printf '%s\n' "$out" | grep -F 'NEW:  wiki/fresh.md' >/dev/null ||
  fail "note absent from the vault was not reported NEW"
printf '%s\n' "$out" | grep -F 'have: wiki/known.md' >/dev/null ||
  fail "note present in the vault was not reported as have:"
printf '%s\n' "$out" | grep -F 'no clone at' >/dev/null ||
  fail "repo without a clone was not reported"

printf '%s\n' 'project-notes page resolution: ok'
