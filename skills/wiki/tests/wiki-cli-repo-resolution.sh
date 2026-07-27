#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
CLI=$TEST_DIR/../scripts/wiki-cli
TMP=$(mktemp -d "${TMPDIR:-/tmp}/wiki-cli-test.XXXXXX")
trap 'rm -rf -- "$TMP"' EXIT INT TERM

CONSUMER=$TMP/consumer
git init -q "$CONSUMER"
mkdir -p "$CONSUMER/wiki/concepts" "$CONSUMER/nested/directory"
printf '%s\n' '# Test concept' 'hardware authentication' >"$CONSUMER/wiki/concepts/test.md"

stats=$(cd "$CONSUMER/nested/directory" && "$CLI" stats)
printf '%s\n' "$stats" | grep -F "Vault:           $CONSUMER/wiki" >/dev/null

search=$(cd "$CONSUMER" && "$CLI" search 'hardware authentication')
printf '%s\n' "$search" | grep -F 'wiki/concepts/test.md' >/dev/null

EMPTY=$TMP/empty
git init -q "$EMPTY"
if (cd "$EMPTY" && "$CLI" stats) >"$TMP/empty.out" 2>"$TMP/empty.err"; then
  printf '%s\n' 'expected a repository without wiki/ to fail' >&2
  exit 1
fi
grep -F 'target repository wiki is not a directory' "$TMP/empty.err" >/dev/null

printf '%s\n' 'wiki-cli repository resolution: ok'
