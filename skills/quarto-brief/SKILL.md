---
name: quarto-brief
description: Draft, edit, and render DIN 5008-style letters with Quarto. Use for formal letters that require a letterhead and official correspondence.
---

# Quarto Brief

Create German letters in the DIN 5008 Form B layout using Quarto with the
`brief-typst` format. It renders with the Typst engine bundled in Quarto 1.10
or later and needs no TeX installation. The layout follows published Form B
dimensions but isn't certified against the full DIN 5008 standard.

## Rendering

```bash
quarto render <file>.qmd
```

## Installing the Extension

If a project does not yet have `_extensions/brief/`, install the format:

```bash
quarto add mavam/quarto-brief
```

## Writing a Letter

Every `.qmd` file must set `format: brief-typst` and provide frontmatter for
sender, recipient, and letter metadata. The body is plain Markdown placed after
the frontmatter.

### Minimal example

```yaml
---
format: brief-typst
author:
  - name: Jane Doe
    email: jane@example.com
    phone: +49 30 1234567
    affiliation:
      - address: Musterstraße 1
        postal-code: 10115
        city: Berlin
address:
  - Max Mustermann
  - Beispielweg 42
  - 80331 München
subject: Ihr Schreiben vom 1. März 2026
opening: Sehr geehrter Herr Mustermann,
closing: Mit freundlichen Grüßen
---

hier folgt der eigentliche Brieftext in Markdown.
```

### Sender details (`author`)

- `author[].name` — name in the letterhead and signature block.
- `author[].email` — email line in the letterhead.
- `author[].phone` — telephone line in the letterhead.
- `author[].url` — website line in the letterhead.
- `author[].affiliation[].address` — street and number.
- `author[].affiliation[].postal-code` — postal code.
- `author[].affiliation[].city` — city.
- `author[].affiliation[].country` — country (optional).

### Recipient (`address`)

Each entry in `address` renders as a separate line in the recipient window:

```yaml
address:
  - Firma GmbH
  - z. Hd. Frau Schmidt
  - Poststraße 7
  - 50667 Köln
```

### Reference fields

Add business reference lines that appear below the letterhead:

- `yourmail` / `yourmail_label` — incoming mail reference and its caption.
- `yourref` / `yourref_label` — recipient's reference number and label.
- `myref` / `myref_label` — sender's reference number and label.
- `customer` / `customer_label` — customer identifier and label.
- `invoice` / `invoice_label` — invoice number and label.
- `place` / `place_label` — location line and label.
- `date_label` — custom caption for the date field.

### Closing elements

- `closing` — complimentary close before the signature.
- `signature` — path to an image placed above the typed name.
- `ps` — postscript appended after the closing.
- `encl[]` — list of enclosures.
- `cc[]` — carbon-copy recipients.

### Date

- `date` — overrides the default (today). Accepts any value Quarto understands.
- `date-format` — controls how the date is formatted (default: `long`).

### Font size

The default is 12pt. Override with a Typst length such as `11pt` or `4mm`:

```yaml
fontsize: 11pt
```

### Fonts

Use Quarto's `mainfont` and `font-paths`. Prefer fonts that Typst bundles or
ship font files with the letter:

```yaml
mainfont: Roboto
font-paths:
  - assets/fonts
```

### Letterhead fields

- `backaddress` — return-address line above the recipient window. Defaults to
  the sender name and address.
- `letterhead_logo` / `letterhead_logo_width` — logo at the top right of the
  first page, for example `assets/logo.svg` and `38mm`.
- `letterhead_background` — Typst file or image drawn behind the first page
  only, from the top-left page corner. Set `false` to turn it off.
- `footer_columns[][]` — footer columns on every page, each a list of lines.
- `text_color` / `muted_color` — hex colors for the text and for the contact
  block, return address, and footer. A set `muted_color` also colors the
  reference-row labels.
- `reference_label_font` / `reference_label_size` — font family and Typst
  length for the reference-row labels only, for example `DejaVu Sans Mono` and
  `7.5pt`. Values, body, and other text keep `mainfont`.

Keep shared letterhead settings in a `_metadata.yml` next to the letters. See
`examples/company` in the extension repository.

### Layout limits

- The recipient address holds at most six lines and must fit the window zone;
  overflow is a render error.
- Frontmatter values are Markdown. Escape a leading `@` or `<tag>`.

### Migrating from `brief-pdf`

The LaTeX-based `brief-pdf` format no longer exists. Change the format to
`brief-typst` and replace LaTeX font options such as `sansfont` or
`mainfontoptions` with `mainfont` and `font-paths`.

## Common Use Cases

### Formal business letter

Include reference fields, subject, and enclosures for official correspondence:

```yaml
yourref: AZ-2026-42
myref: MV-0815
subject: Vertragsunterlagen
encl:
  - Vertrag (2-fach)
  - AGB
```

### Invoice cover letter

Use `invoice`, `customer`, and `date_label` to create an invoice-style header:

```yaml
customer_label: Kundennr.
customer: K-12345
invoice_label: Rechnungsnr.
invoice: "2026-007"
date_label: Rechnungsdatum
```

### Letter with signature image

Place a scanned signature above the printed name:

```yaml
signature: sig.png
closing: Hochachtungsvoll
```
