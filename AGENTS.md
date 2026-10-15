# quarto-brief

`quarto-brief` renders DIN 5008-style German PDF letters with Quarto and Typst
through the `brief-typst` format.

## Setup

Install Lefthook once per clone:

```sh
uvx lefthook install
```

Pushing checks that frontmatter fields remain synchronized. GitHub Actions
runs the same validation and `scripts/test-typst.sh`, which renders
`template.qmd`, `examples/`, and `tests/typst/` and inspects the PDFs, for pull
requests and changes to `main`. Run `bash scripts/test-typst.sh` locally after
layout changes; it needs Poppler.

## Field changes

Keep every supported field aligned across the canonical template partial
`_extensions/brief/partials/typst-show.typ`, the Quarto Wizard schema in
`_extensions/brief/_schema.yml`, and the user-facing reference in `README.md`.
`template.qmd`, an example under `examples/`, or a fixture under
`tests/typst/` must use each field.

Keep examples and fixtures fictional and unbranded. Use fonts that Typst
bundles so rendering doesn't depend on the host.

Update `_extensions/brief/_snippets.json` when a field belongs in the common
insertion snippet. Snippets are representative, not exhaustive.
