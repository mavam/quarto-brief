#!/usr/bin/env bash
#
# Validate that extension field definitions stay in sync across the canonical
# LaTeX and Typst templates, _schema.yml, README.md, and the Typst examples.
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
# 1. Extract extension-specific fields from LaTeX templates (canonical)
# ---------------------------------------------------------------------------
# Matches $if(field)$ and $for(field)$, then strips the Pandoc syntax and
# excludes Quarto built-in variables.
latex_fields=$(
  grep -ohE '\$(if|for)\([a-z_]+\)\$' \
    _extensions/brief/partials/before-body.tex \
    _extensions/brief/partials/after-body.tex \
  | grep -oE '\([a-z_]+\)' \
  | tr -d '()' \
  | grep -vE '^(authors?|it)$' \
  | sort -u
)

# ---------------------------------------------------------------------------
# 2. Extract Typst fields from the typst-show.typ partial
# ---------------------------------------------------------------------------
# Same pattern as above; also excludes Quarto built-ins that the partial maps.
typst_fields=$(
  grep -ohE '\$(if|for)\([a-z_]+\)\$' \
    _extensions/brief/partials/typst-show.typ \
  | grep -oE '\([a-z_]+\)' \
  | tr -d '()' \
  | grep -vE '^(authors?|it|lang|region|mainfont)$' \
  | sort -u
)

# ---------------------------------------------------------------------------
# 3. Extract fields from _schema.yml, per format
# ---------------------------------------------------------------------------
# Fields sit at exactly 4-space indent under formats.<format>.
schema_fields() {
  awk -v format="  $1:" '
    /^  [a-z-]+:/ { in_format = ($0 == format) }
    in_format && /^    [a-z_]+:/ { sub(/^ +/, ""); sub(/:.*/, ""); print }
  ' _extensions/brief/_schema.yml | sort -u
}
schema_pdf_fields=$(schema_fields brief-pdf)
schema_typst_fields=$(schema_fields brief-typst)

# ---------------------------------------------------------------------------
# 4. Extract fields from README.md "Frontmatter overview" section
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
# 5. Extract keys from the Typst examples and test fixtures
# ---------------------------------------------------------------------------
example_fields=$(
  cat examples/*/*.qmd examples/*/_metadata.yml tests/typst/*.qmd 2>/dev/null \
  | grep -oE '^ *[a-z_]+:' \
  | sed 's/^ *//; s/://' \
  | sort -u
)

all_fields=$(printf '%s\n%s\n' "$latex_fields" "$typst_fields" | sed '/^$/d' | sort -u)

# ---------------------------------------------------------------------------
# Compare the synced sources
# ---------------------------------------------------------------------------
compare_sets 'LaTeX templates' '_schema.yml (brief-pdf)' "$latex_fields" "$schema_pdf_fields"
compare_sets 'Typst templates' '_schema.yml (brief-typst)' "$typst_fields" "$schema_typst_fields"
compare_sets 'LaTeX and Typst templates' 'README.md' "$all_fields" "$readme_fields"

# The Typst format must support every LaTeX field.
missing=$(comm -23 \
  <(printf '%s\n' "$latex_fields" | sed '/^$/d') \
  <(printf '%s\n' "$typst_fields" | sed '/^$/d'))
if [[ -n "$missing" ]]; then
  error 'Fields in LaTeX templates but missing from Typst templates:'
  print_list "$missing"
fi

# The Typst examples and fixtures together must exercise every Typst field.
missing=$(comm -23 \
  <(printf '%s\n' "$typst_fields" | sed '/^$/d') \
  <(printf '%s\n' "$example_fields" | sed '/^$/d'))
if [[ -n "$missing" ]]; then
  error 'Fields in Typst templates but not used in examples/ or tests/typst/:'
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
    <(printf '%s\n' "$all_fields" | sed '/^$/d') \
    <(printf '%s\n' "$snippet_fields" | sed '/^$/d'))
  if [[ -n "$extra" ]]; then
    error 'Fields in _snippets.json but not in templates:'
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
