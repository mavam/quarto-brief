#!/usr/bin/env bash
#
# Render the root template, examples, and fixtures, then inspect the PDFs.
#
# Outputs go to .build/typst (ignored by Git). Set RASTER=1 to also write PNG
# previews to .build/typst/png for visual review.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

out=.build/typst
rm -rf "$out"

inputs=(
  template.qmd
  examples/generic/letter.qmd
  examples/company/letter.qmd
  tests/typst/minimal.qmd
  tests/typst/multipage.qmd
  tests/typst/plain-multipage.qmd
  tests/typst/special.qmd
  tests/typst/six-line.qmd
)

for input in "${inputs[@]}"; do
  printf 'Rendering %s\n' "$input"
  quarto render "$input" --to brief-typst --output-dir "$out" --quiet
done

# Explicitly disabling the background must match the undecorated default.
printf 'Rendering examples/company/letter.qmd with background explicitly disabled\n'
quarto render examples/company/letter.qmd --to brief-typst --output-dir "$out/plain" \
  -M letterhead_background:false --quiet

python3 tests/typst/check.py "$out"

if [[ "${RASTER:-0}" == 1 ]]; then
  mkdir -p "$out/png"
  for input in "${inputs[@]}"; do
    pdf="$out/${input%.qmd}.pdf"
    pdftoppm -r 100 -png "$pdf" "$out/png/$(echo "${input%.qmd}" | tr / -)"
  done
  pdftoppm -r 100 -png "$out/plain/examples/company/letter.pdf" "$out/png/examples-company-letter-plain"
  pdftoppm -r 100 -png -gray "$out/examples/company/letter.pdf" "$out/png/examples-company-letter-gray"
  printf 'PNG previews: %s/png\n' "$out"
fi
