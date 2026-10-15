#!/usr/bin/env bash
#
# Validate that extension field definitions stay in sync across the canonical
# Typst template partial, _schema.yml, README.md, and the template, examples,
# and test fixtures.
# Also validate that _snippets.json is valid JSON and only references known
# fields.
#
# See AGENTS.md for the maintenance checklist.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

errors=0

error() {
  printf 'ERROR: %s\n' "$*"
  errors=$((errors + 1))
}

print_list() {
  printf '%s\n' "$1" | sed '/^$/d; s/^/  - /'
}

compare_sets() {
  local left_name=$1
  local right_name=$2
  local left_set=$3
  local right_set=$4
  local missing
  local extra

  missing=$(comm -23 \
    <(printf '%s\n' "$left_set" | sed '/^$/d') \
    <(printf '%s\n' "$right_set" | sed '/^$/d'))
  if [[ -n "$missing" ]]; then
    error "Fields in $left_name but missing from $right_name:"
    print_list "$missing"
  fi

  extra=$(comm -13 \
    <(printf '%s\n' "$left_set" | sed '/^$/d') \
    <(printf '%s\n' "$right_set" | sed '/^$/d'))
  if [[ -n "$extra" ]]; then
    error "Fields in $right_name but not in $left_name:"
    print_list "$extra"
  fi
}

# ---------------------------------------------------------------------------
# 1. Extract fields from the typst-show.typ partial (canonical)
# ---------------------------------------------------------------------------
# Matches $if(field)$ and $for(field)$, then strips the Pandoc syntax and
# excludes Quarto built-in variables that the partial maps.
template_fields=$(
  grep -ohE '\$(if|for)\([a-z_]+\)\$' \
    _extensions/brief/partials/typst-show.typ \
  | grep -oE '\([a-z_]+\)' \
  | tr -d '()' \
  | grep -vE '^(authors?|it|lang|region|mainfont)$' \
  | sort -u
)

# ---------------------------------------------------------------------------
# 2. Extract fields from _schema.yml
# ---------------------------------------------------------------------------
# Fields sit at exactly 4-space indent under formats.brief-typst.
schema_fields=$(
  awk '
    /^  [a-z-]+:/ { in_format = ($0 == "  brief-typst:") }
    in_format && /^    [a-z_]+:/ { sub(/^ +/, ""); sub(/:.*/, ""); print }
  ' _extensions/brief/_schema.yml | sort -u
)

# ---------------------------------------------------------------------------
# 3. Extract fields from README.md "Frontmatter overview" section
# ---------------------------------------------------------------------------
# Pull backtick-quoted identifiers from list items, strip [] suffixes, and
# exclude Quarto built-in author metadata.
readme_fields=$(
  sed -n '/^### .*Frontmatter overview/,/^##[# ]/p' README.md \
  | grep '^- ' \
  | grep -oE '`[^`]+`' \
  | sed 's/`//g; s/\[\].*//g' \
  | grep -vE '^author$' \
  | sort -u
)

# ---------------------------------------------------------------------------
# 4. Extract keys from the template, examples, and test fixtures
# ---------------------------------------------------------------------------
example_fields=$(
  cat template.qmd examples/*/*.qmd examples/*/_metadata.yml tests/typst/*.qmd 2>/dev/null \
  | grep -oE '^ *[a-z_]+:' \
  | sed 's/^ *//; s/://' \
  | sort -u
)

# ---------------------------------------------------------------------------
# Compare the synced sources
# ---------------------------------------------------------------------------
compare_sets 'typst-show.typ' '_schema.yml' "$template_fields" "$schema_fields"
compare_sets 'typst-show.typ' 'README.md' "$template_fields" "$readme_fields"

# The template, examples, and fixtures together must exercise every field.
missing=$(comm -23 \
  <(printf '%s\n' "$template_fields" | sed '/^$/d') \
  <(printf '%s\n' "$example_fields" | sed '/^$/d'))
if [[ -n "$missing" ]]; then
  error 'Fields in typst-show.typ but not used in template.qmd, examples/, or tests/typst/:'
  print_list "$missing"
fi

# ---------------------------------------------------------------------------
# Validate _snippets.json
# ---------------------------------------------------------------------------
if ! python3 -m json.tool _extensions/brief/_snippets.json > /dev/null 2>&1; then
  error '_extensions/brief/_snippets.json is not valid JSON'
fi

# Check that any YAML-key-like fields in snippet bodies are known.
snippet_fields=$(
  grep -ohE '"[a-z_]+:' _extensions/brief/_snippets.json \
  | sed 's/"//; s/://' \
  | grep -vE '^format$' \
  | sort -u
) || true

if [[ -n "${snippet_fields:-}" ]]; then
  extra=$(comm -13 \
    <(printf '%s\n' "$template_fields" | sed '/^$/d') \
    <(printf '%s\n' "$snippet_fields" | sed '/^$/d'))
  if [[ -n "$extra" ]]; then
    error 'Fields in _snippets.json but not in typst-show.typ:'
    print_list "$extra"
  fi
fi

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
printf '\n'
if [[ $errors -gt 0 ]]; then
  printf 'FAILED: %s sync issue(s) found.\n' "$errors"
  printf 'See AGENTS.md for the field-change checklist.\n'
  exit 1
fi

printf '✓ All extension field sources are in sync.\n'
