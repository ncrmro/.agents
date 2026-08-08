#!/usr/bin/env bash

set -euo pipefail
umask 077

case $0 in
  */*) script_dir=${0%/*} ;;
  *) script_dir=. ;;
esac
skill_dir=$script_dir/..

# shellcheck source=lib/require.sh
. "$script_dir/lib/require.sh"

require_tool mktemp \
  'nix profile add nixpkgs#coreutils'
require_tool pandoc \
  'nix profile add nixpkgs#pandoc'
require_tool weasyprint \
  'nix profile add nixpkgs#weasyprint'

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s REPORT.md\n' "${0##*/}" >&2
  exit 2
fi

report=$1
if [ ! -f "$report" ] || [ ! -r "$report" ]; then
  printf '%s: the report is not a readable file: %s\n' "${0##*/}" "$report" >&2
  exit 2
fi

report_name=${report##*/}
report_name=${report_name%.*}
if [ -z "$report_name" ]; then
  report_name=finance-report
fi

output_dir=$(mktemp -d "${TMPDIR:-/tmp}/finance-report.XXXXXXXX")
html_report=$output_dir/$report_name.html
pdf_report=$output_dir/$report_name.pdf

pandoc \
  --from=markdown \
  --to=html5 \
  --standalone \
  --embed-resources \
  --css="$skill_dir/assets/report.css" \
  --output="$html_report" \
  "$report"

weasyprint "$html_report" "$pdf_report"

if [ ! -s "$html_report" ] || [ ! -s "$pdf_report" ]; then
  printf '%s: the renderer created an empty output file.\n' "${0##*/}" >&2
  exit 1
fi

printf 'Temporary directory: %s\n' "$output_dir"
printf 'HTML report: %s\n' "$html_report"
printf 'PDF report: %s\n' "$pdf_report"
printf 'These files contain sensitive data. Remove the directory after review.\n'
