# quarto-brief

`quarto-brief` renders DIN 5008-compliant German PDF letters with Quarto and
the KOMA-Script `scrlttr2` class.

## Setup

Install Lefthook once per clone:

```sh
uvx lefthook install
```

Pushing checks that frontmatter fields remain synchronized. GitHub Actions
runs the same validation and renders the example for pull requests and changes
to `main`. No need to run checks manually.

## Field changes

Keep every supported field aligned across the canonical templates in
`_extensions/brief/partials/`, the Quarto Wizard schema in
`_extensions/brief/_schema.yml`, the user-facing reference in `README.md`, and
the complete example in `template.qmd`.

Update `_extensions/brief/_snippets.json` when a field belongs in the common
insertion snippet. Snippets are representative, not exhaustive.
