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
# Never touch the real cache, and keep the resolution assertions below live:
# they add clones between runs, which a warm entry would hide.
export PROJECT_NOTES_CACHE_DIR=$TMP/cache PROJECT_NOTES_CACHE_TTL=0
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

# --- response cache ---------------------------------------------------------
# A repeat call must replay rather than re-query, --refresh must bypass, and a
# degraded answer must never be stored — a cached "tea request failed" would
# read as "no open work" for the rest of the window.
cache=$TMP/cache2
# Stub forges so the assertions below depend on the cache, not on whether gh
# and tea are installed, logged in, or reachable.
mkdir -p "$TMP/bin"
printf '#!/bin/sh\nexit 0\n' >"$TMP/bin/gh"
printf '#!/bin/sh\nprintf "[]\\n"\n' >"$TMP/bin/tea"
chmod +x "$TMP/bin/gh" "$TMP/bin/tea"

(
  export PROJECT_NOTES_CACHE_DIR=$cache PROJECT_NOTES_CACHE_TTL=30
  export PATH=$TMP/bin:$PATH

  first=$("$GATHER" demo 2>/dev/null) || fail "gather.sh exited non-zero (cache warm-up)"
  if printf '%s\n' "$first" | grep -F '> cached' >/dev/null; then
    fail "first run replayed a cache entry"
  fi
  [ "$(find "$cache" -name '*.md' | wc -l)" -eq 1 ] ||
    fail "first run did not store exactly one cache entry"

  second=$("$GATHER" demo 2>/dev/null) || fail "gather.sh exited non-zero (cached)"
  printf '%s\n' "$second" | grep -F '> cached' >/dev/null ||
    fail "repeat run did not replay the cache entry"
  [ "$(printf '%s\n' "$second" | grep -vF '> cached' | grep -c .)" -gt 0 ] ||
    fail "replayed entry had no body"

  if "$GATHER" demo --refresh 2>/dev/null | grep -F '> cached' >/dev/null; then
    fail "--refresh replayed the cache entry"
  fi

  # A different argument set is a different question, so a different entry.
  "$GATHER" demo --since 2026-01-01 >/dev/null 2>&1 ||
    fail "gather.sh --since exited non-zero"
  [ "$(find "$cache" -name '*.md' | wc -l)" -eq 2 ] ||
    fail "--since did not get its own cache entry"

  # A missing page fails and leaves nothing behind.
  if "$GATHER" nosuch >/dev/null 2>&1; then
    fail "missing page exited zero under the cache"
  fi
  [ "$(find "$cache" -name '*.md' | wc -l)" -eq 2 ] ||
    fail "a failed run was cached"

  # Degraded output — here a Forgejo repo whose tea call fails — stays live,
  # so the next call retries instead of reporting an empty forge for 30 minutes.
  rm -rf "$cache"
  printf '#!/bin/sh\nexit 1\n' >"$TMP/bin/tea"
  "$GATHER" demo >"$TMP/degraded.out" 2>/dev/null ||
    fail "gather.sh exited non-zero with a failing tea"
  grep -F 'tea request failed' "$TMP/degraded.out" >/dev/null ||
    fail "failing tea did not report a failed request"
  [ "$(find "$cache" -name '*.md' 2>/dev/null | wc -l)" -eq 0 ] ||
    fail "a degraded run (tea request failed) was cached"
  printf '#!/bin/sh\nprintf "[]\\n"\n' >"$TMP/bin/tea"

  # A bad --max-age is a hard error, not a silently unknown flag.
  if "$GATHER" demo --max-age soon >/dev/null 2>"$TMP/maxage.err"; then
    fail "expected --max-age soon to exit non-zero"
  fi
  grep -F 'whole number of minutes' "$TMP/maxage.err" >/dev/null ||
    fail "bad --max-age did not explain itself"
) || exit 1

printf '%s\n' 'project-notes page resolution + response cache: ok'
