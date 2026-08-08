#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
CLI=$TEST_DIR/../scripts/wiki-cli
TMP=$(mktemp -d "${TMPDIR:-/tmp}/wiki-cli-link-test.XXXXXX")
trap 'rm -rf -- "$TMP"' EXIT INT TERM

CONSUMER=$TMP/consumer
git init -q "$CONSUMER"
mkdir -p "$CONSUMER/wiki/a" "$CONSUMER/wiki/b" "$CONSUMER/wiki/nested"
printf '%s\n' \
  '# Source' \
  '[[Target]]' \
  '[[Missing]]' \
  '[[Duplicate]]' \
  '[relative](nested/target.md)' \
  '[external](https://example.com)' >"$CONSUMER/wiki/source.md"
printf '%s\n' '# Target' >"$CONSUMER/wiki/Target.md"
printf '%s\n' '# Duplicate A' >"$CONSUMER/wiki/a/Duplicate.md"
printf '%s\n' '# Duplicate B' >"$CONSUMER/wiki/b/Duplicate.md"
printf '%s\n' '# Relative target' >"$CONSUMER/wiki/nested/target.md"
printf '%s\n' '[[MissingUppercaseExtension]]' >"$CONSUMER/wiki/uppercase.MD"

if (cd "$CONSUMER" && "$CLI" check) >"$TMP/check.out"; then
  printf '%s\n' 'expected missing and ambiguous links to fail the audit' >&2
  exit 1
fi
printf '%s\n' \
  'source.md:3: missing: Missing' \
  'source.md:4: ambiguous: Duplicate -> a/Duplicate.md | b/Duplicate.md' \
  'uppercase.MD:1: missing: MissingUppercaseExtension' >"$TMP/check.expected"
diff -u "$TMP/check.expected" "$TMP/check.out"

backlinks=$(cd "$CONSUMER" && "$CLI" backlinks Target)
[[ $backlinks == $'source.md:2\tTarget' ]]

stats=$(cd "$CONSUMER" && "$CLI" stats)
printf '%s\n' "$stats" | grep -F 'Internal links:  5' >/dev/null
printf '%s\n' "$stats" | grep -F 'Missing links:   2' >/dev/null
printf '%s\n' "$stats" | grep -F 'Ambiguous links: 1' >/dev/null

printf '%s\n' 'wiki-cli link audit: ok'
