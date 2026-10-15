# Company letterhead

A fictional company letterhead for the `brief-typst` format. The extension
stays generic; this directory supplies the branding through `_metadata.yml`.

## Render a letter

1. Copy `letter.qmd` to a new file in this directory.
2. Edit the recipient, subject, greeting, body, closing, and reference number.
3. Run `quarto render <file>.qmd`.

## Files

- `_metadata.yml`: colors, logo, return address, footer columns, and the
  reference-label typography shared by every letter here.
- `letter.qmd`: sample letter.
- `assets/logo.svg`: placeholder logo.

The reference labels use DejaVu Sans Mono, which Typst bundles, so the example
renders without extra fonts. To use your own fonts, set Quarto's `mainfont` and
`font-paths` options.
