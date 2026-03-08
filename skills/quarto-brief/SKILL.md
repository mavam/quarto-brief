---
name: quarto-brief
description: Draft, edit, and render DIN 5008-style letters with Quarto. Use for formal letters that require a letterhead and official correspondence.
---

# Quarto Brief

Create DIN 5008-compliant German-style letters using Quarto with the `brief-pdf`
format. The extension uses the `scrlttr2` LaTeX document class.

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

Every `.qmd` file must set `format: brief-pdf` and provide frontmatter for
sender, recipient, and letter metadata. The body is plain Markdown placed after
the frontmatter.

### Minimal example

```yaml
---
format: brief-pdf
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
  - :0331 München
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

The default is 12pt. Override with:

```yaml
fontsize: 11pt
```

### Custom fonts

Adjust `mainfont` and `sansfont` for the letter body and address fields:

```yaml
mainfont: Roboto
mainfontoptions:
  - Extension=.ttf
  - UprightFont=*-Regular
  - BoldFont=*-Bold
  - ItalicFont=*-Italic
  - BoldItalicFont=*-BoldItalic
sansfont: Roboto
sansfontoptions:
  - Extension=.ttf
  - UprightFont=*-Regular
  - BoldFont=*-Bold
  - ItalicFont=*-Italic
  - BoldItalicFont=*-BoldItalic
```

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
