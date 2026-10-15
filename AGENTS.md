# quarto-brief

`quarto-brief` renders DIN 5008-style German PDF letters with Quarto. The
`brief-pdf` format uses the KOMA-Script `scrlttr2` class; the experimental
`brief-typst` format uses Typst and must not change the LaTeX output.

## Setup

Install Lefthook once per clone:

```sh
uvx lefthook install
```

Pushing checks that frontmatter fields remain synchronized. GitHub Actions
runs the same validation, renders the example, and runs
`scripts/test-typst.sh`, which renders `examples/` and `tests/typst/` and
inspects the PDFs, for pull requests and changes to `main`. Run
`bash scripts/test-typst.sh` locally after Typst layout changes; it needs
Poppler.

## Field changes

Keep every supported field aligned across the canonical templates in
`_extensions/brief/partials/`, the Quarto Wizard schema in
`_extensions/brief/_schema.yml`, the user-facing reference in `README.md`, and
the complete example in `template.qmd`. Typst-only fields go in
`typst-show.typ` and the `brief-typst` schema, and an example or fixture under
`examples/` or `tests/typst/` must use each one.

Keep examples and fixtures fictional and unbranded. Use fonts that Typst
bundles so rendering doesn't depend on the host.

Update `_extensions/brief/_snippets.json` when a field belongs in the common
insertion snippet. Snippets are representative, not exhaustive.
