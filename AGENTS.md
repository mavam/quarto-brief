# quarto-brief

`quarto-brief` is a Quarto extension for DIN 5008-compliant German letters based
on the `scrlttr2` LaTeX class.

## Setup

Install Lefthook once per clone:

```bash
uvx lefthook install
```

Pushing runs the quality gates automatically. Don't run checks manually.

## Field changes

Update `_extensions/brief/_snippets.json` when a field belongs in the common
insertion snippet. Keep every supported field in `template.qmd`, then render it:

```bash
quarto render template.qmd
```
