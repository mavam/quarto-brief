#!/usr/bin/env bash
#
# Validate that extension field definitions stay in sync across the canonical
# LaTeX templates, _schema.yml, and README.md. Also validate that
# _snippets.json is valid JSON and only references known fields.
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
# 2. Extract fields from _schema.yml
# ---------------------------------------------------------------------------
# Fields sit at exactly 4-space indent under formats.brief-pdf.
schema_fields=$(
  grep -E '^    [a-z_]+:' _extensions/brief/_schema.yml \
  | sed 's/^ *//; s/:.*//' \
  | sort -u
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
# Compare the synced sources
# ---------------------------------------------------------------------------
compare_sets 'LaTeX templates' '_schema.yml' "$latex_fields" "$schema_fields"
compare_sets 'LaTeX templates' 'README.md' "$latex_fields" "$readme_fields"

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
    <(printf '%s\n' "$latex_fields" | sed '/^$/d') \
    <(printf '%s\n' "$snippet_fields" | sed '/^$/d'))
  if [[ -n "$extra" ]]; then
    error 'Fields in _snippets.json but not in LaTeX templates:'
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
