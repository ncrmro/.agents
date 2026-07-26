#!/usr/bin/env bash
# personas.sh — compose atomic role/org/bio fragments into a persona matrix.
#
# The interesting feedback comes from variants: the same role at a different
# org, or the same org with different experience, reacts differently to the
# same page. This builds every combination so a deep matrix costs one command.
#
#   personas.sh --role R [--role R2 ...] [--org O ...] --bio B [--bio B2 ...]
#               [--out DIR] [--dry-run] [--force] [--limit N]
#
#   --role       required, repeatable. The job they do.
#   --org        optional, repeatable. Pass "" for an unaffiliated variant.
#   --bio        required, repeatable. Sentences an agent can act on.
#   --roles-from building-block file, repeatable. Adds every entry as a --role.
#   --orgs-from  building-block file, repeatable. Adds every entry as an --org.
#   --bios-from  building-block file, repeatable. Adds every entry as a --bio.
#   --out        output directory (default: docs/personas)
#   --dry-run    list what would be written, write nothing
#   --force      overwrite existing files (default: skip, report, exit non-zero)
#   --limit      refuse to generate more than N personas (default 60)
#
# Building-block files keep a reusable fragment library on disk instead of in
# shell history — see assets/PERSONA.{role,org,bio}.md. In one, each "## "
# heading starts an entry: the body beneath it is the fragment, or the heading
# itself when there is no body. Text before the first heading and anything in
# an HTML comment is ignored, so the file can explain itself. File and inline
# fragments combine, and a bare --org "" adds the unaffiliated variant.
#
# Files are named <role-slug>[-<org-slug>][-v<n>].md and follow
# assets/PERSONA.template.md. Bios are numbered per role+org pair, so
# regenerating with the same arguments is stable.
set -euo pipefail

roles=() orgs=() bios=()
out="docs/personas" dry_run=0 force=0 limit=60

die() { printf 'personas.sh: %s\n' "$*" >&2; exit 2; }

# Emit each "## " entry of a building-block file as a NUL-terminated fragment:
# the body when it has one, else the heading itself. Ignores the preamble
# before the first heading and any HTML comment, so the file can document
# itself without polluting the matrix.
fragments() {
  awk '
    function flush(   text) {
      text = body
      gsub(/^[ \t\r\n]+/, "", text); gsub(/[ \t\r\n]+$/, "", text)
      if (text == "") text = label
      printf "%s%c", text, 0
    }
    /<!--/ { in_comment = 1 }
    in_comment { if (/-->/) in_comment = 0; next }
    /^##[ \t]/ {
      if (label != "") flush()
      label = $0; sub(/^##[ \t]+/, "", label); body = ""
      next
    }
    label != "" { body = body $0 "\n" }
    END { if (label != "") flush() }
  ' "$1"
}

read_into() {
  local -n target=$1
  local file=$2 frag
  [ -r "$file" ] || die "cannot read building-block file: $file"
  while IFS= read -r -d '' frag; do target+=("$frag"); done < <(fragments "$file")
}

while [ $# -gt 0 ]; do
  case "$1" in
    --role)    [ $# -ge 2 ] || die "--role needs a value"; roles+=("$2"); shift 2 ;;
    --org)     [ $# -ge 2 ] || die "--org needs a value";  orgs+=("$2");  shift 2 ;;
    --bio)     [ $# -ge 2 ] || die "--bio needs a value";  bios+=("$2");  shift 2 ;;
    --roles-from) [ $# -ge 2 ] || die "--roles-from needs a file"; read_into roles "$2"; shift 2 ;;
    --orgs-from)  [ $# -ge 2 ] || die "--orgs-from needs a file";  read_into orgs  "$2"; shift 2 ;;
    --bios-from)  [ $# -ge 2 ] || die "--bios-from needs a file";  read_into bios  "$2"; shift 2 ;;
    --out)     [ $# -ge 2 ] || die "--out needs a value";  out="$2";      shift 2 ;;
    --limit)   [ $# -ge 2 ] || die "--limit needs a value"; limit="$2";   shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    --force)   force=1; shift ;;
    -h|--help) sed -n '2,31p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         die "unknown argument: $1 (try --help)" ;;
  esac
done

[ ${#roles[@]} -gt 0 ] || die "at least one --role is required"
[ ${#bios[@]}  -gt 0 ] || die "at least one --bio is required"
# No --org given means one unaffiliated variant, not zero personas.
[ ${#orgs[@]}  -gt 0 ] || orgs=("")

total=$(( ${#roles[@]} * ${#orgs[@]} * ${#bios[@]} ))
if [ "$total" -gt "$limit" ]; then
  die "$total personas exceeds --limit $limit; raise the limit if that is intended"
fi

slug() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-\+//' -e 's/-\+$//'
}

[ "$dry_run" -eq 1 ] || mkdir -p "$out"

written=0 skipped=0
for role in "${roles[@]}"; do
  for org in "${orgs[@]}"; do
    n=0
    for bio in "${bios[@]}"; do
      n=$(( n + 1 ))

      name="$role"; [ -n "$org" ] && name="$role — $org"
      file="$(slug "$role")"
      [ -n "$org" ] && file="$file-$(slug "$org")"
      # Only disambiguate when a role+org pair carries several bios.
      [ ${#bios[@]} -gt 1 ] && file="$file-v$n"
      path="$out/$file.md"

      if [ "$dry_run" -eq 1 ]; then
        printf '%s\t%s\n' "$path" "$name"
        written=$(( written + 1 ))
        continue
      fi

      if [ -e "$path" ] && [ "$force" -eq 0 ]; then
        printf 'skip (exists): %s\n' "$path" >&2
        skipped=$(( skipped + 1 ))
        continue
      fi

      {
        printf '# %s\n\n' "$name"
        printf '| | |\n| --- | --- |\n'
        printf '| **Role** | %s |\n' "$role"
        [ -n "$org" ] && printf '| **Org** | %s |\n' "$org"
        printf '| **Status** | scenario |\n\n'
        printf '## Bio\n\n%s\n\n' "$bio"
        printf '## What they are trying to do\n\n- TODO\n\n'
        printf '## What would make them walk\n\n- TODO\n\n'
        printf '## Related\n\n- Requirements written for them: TODO\n'
        printf -- '- Milestones demoed to them: TODO\n'
      } > "$path"

      printf 'wrote: %s\n' "$path"
      written=$(( written + 1 ))
    done
  done
done

if [ "$dry_run" -eq 1 ]; then
  printf '\n%d personas would be written to %s\n' "$written" "$out"
  exit 0
fi

printf '\n%d written, %d skipped (%d combinations)\n' "$written" "$skipped" "$total"
# A skip is a real outcome — the caller asked for a file that already exists.
[ "$skipped" -eq 0 ] || exit 1
