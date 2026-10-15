# 📮 Brief — DIN 5008-style letters with Quarto

This Quarto extension renders German business letters modeled on the
[DIN 5008](https://de.wikipedia.org/wiki/DIN_5008) Form B layout with
[Typst](https://typst.app).

## 🚀 Installation

Install [Quarto](https://quarto.org/docs/get-started/) 1.10 or later, which
bundles Typst. No TeX installation is required. Create a letter from the
template:

```sh
quarto use template mavam/quarto-brief
```

To add the format to an existing project instead:

```sh
quarto add mavam/quarto-brief
```

## ✨ Usage

Set the format in the frontmatter and write the letter body in Markdown:

```yaml
---
format: brief-typst
---
```

Then render the letter:

```sh
quarto render template.qmd
```

The sample [template.qmd](template.qmd) shows the common frontmatter fields.
The [examples](examples) directory contains a generic letter and a fictional
company letterhead that shares its settings through `_metadata.yml`.

> [!NOTE]
> Earlier releases provided a LaTeX-based `brief-pdf` format. It has been
> removed. To migrate a letter, change `format: brief-pdf` to
> `format: brief-typst` and replace LaTeX-specific options such as
> `sansfont` or `mainfontoptions` with the Typst options below.

## ⚙️ Configuration

### 🗂️ Frontmatter overview

- `author[].name`: sender name shown in the contact block and signature block.
- `author[].email`: email line in the contact block.
- `author[].phone`: telephone line in the contact block.
- `author[].url`: sender website in the contact block.
- `author[].affiliation[].address`: street and number for the sender address.
- `author[].affiliation[].postal-code`: postal code for the sender address.
- `author[].affiliation[].city`: sender city.
- `author[].affiliation[].country`: sender country (optional).
- `signature`: path to an image that appears above the typed sender name.
- `address[]`: each entry renders as a separate line in the recipient block.
- `date`: overrides the default date with your own value.
- `date_label`: custom caption for the date (for example, “Datum”).
- `yourmail` / `yourmail_label`: incoming correspondence reference plus caption.
- `yourref` / `yourref_label`: recipient reference designation and label.
- `myref` / `myref_label`: sender reference designation and label.
- `customer` / `customer_label`: customer identifier and label.
- `invoice` / `invoice_label`: invoice number and label.
- `place` / `place_label`: location line (for example, “Berlin”) and label.
- `subject`: bold subject line before the body text.
- `opening`: greeting that precedes the main letter text.
- `closing`: complimentary close placed before the signature block.
- `ps`: optional postscript appended after the closing.
- `encl[]`: list of enclosures printed at the end of the letter.
- `cc[]`: carbon copy recipients rendered after enclosures.
- `fontsize`: base font size as a Typst length; defaults to 12pt.
- `backaddress`: return-address line above the recipient window.
- `letterhead_logo`: logo image at the top right of the first page.
- `letterhead_logo_width`: logo width as a Typst length such as 38mm.
- `letterhead_background`: Typst file or image drawn behind the first page,
  anchored at the top-left page corner; `false` turns it off.
- `footer_columns[][]`: footer columns on every page, each a list of lines.
- `text_color`: main text color as a hex value such as #0E1017.
- `muted_color`: color of the contact block, return address, and footer; when
  set, also colors the reference-row labels.
- `reference_label_font`: font family for the reference-row labels; values keep
  the main font.
- `reference_label_size`: reference-row label size as a Typst length such as
  7.5pt; defaults to 0.73em.

### 📐 Layout

The first page uses Form B zones: the outer address window starts 20 mm from
the left edge, with a 5 mm text inset. Return-address, recipient,
reference-row, and body text align at 25 mm. The recipient zone spans
62.7–90 mm from the top; fold and punch marks appear on the left edge.
Addresses support up to six lines and must fit the zone. The sender contact
block is right-aligned with its last line on the return-address baseline.
Pages after the first repeat the subject and date in a small header, and
multi-page letters show page numbers.

The layout uses published Form B dimensions but hasn't been verified against
the full DIN 5008:2020 standard. The [geometry audit](docs/geometry.md)
distinguishes published zone dimensions from typographic choices and records
the remaining conformity checks.

### ✏️ Font size

The default font size is 12pt. `fontsize` takes a Typst length:

```yaml
---
fontsize: 11pt
---
```

Units such as `pt` and `mm` work; `ex` doesn't. To keep addresses within the
recipient zone, prefer common sizes such as `10pt`, `11pt`, or `12pt`.

### 🔤 Fonts

Use Quarto's `mainfont` and `font-paths` options. For example, to use
[Roboto](https://fonts.google.com/specimen/Roboto), put its font files in
`assets/fonts` and set:

```yaml
---
mainfont: Roboto
font-paths:
  - assets/fonts
---
```

`reference_label_font` and `reference_label_size` change only the
reference-row labels; values, body, and other text keep `mainfont`.

### 🏢 Letterheads

Branding stays out of the extension. Set `letterhead_logo`, `backaddress`,
`footer_columns`, `text_color`, `muted_color`, `reference_label_font`,
`reference_label_size`, and `letterhead_background` per letter or in a shared
`_metadata.yml`:

```yaml
---
format:
  brief-typst:
    mainfont: Source Sans 3
    font-paths:
      - assets/fonts
    reference_label_font: DejaVu Sans Mono
    reference_label_size: 7.5pt
    letterhead_logo: assets/logo.svg
    letterhead_logo_width: 40mm
    backaddress: Example GmbH · Musterweg 5 · 10115 Berlin
    footer_columns:
      - [Example GmbH, Musterweg 5, 10115 Berlin]
      - [https://example.com, info@example.com]
---
```

Letters have no background decoration by default. `letterhead_background`
points to a Typst file or an image that the format draws behind the first page
only, with its origin at the top-left page corner. Keep decoration clear of the
recipient window and the text. A Typst file can import its own helpers with
paths relative to itself. To turn off a background set in `_metadata.yml`, set
`letterhead_background: false` in the letter or render with
`-M letterhead_background:false`.

### ⚠️ Markdown in frontmatter

Frontmatter values are Markdown. Escape characters that Markdown interprets,
such as a leading `@` (citation) or `<tag>` (raw HTML).

## 🙏 Credits

I got inspired by Mickaël Canouil's
[quarto-letter](https://github.com/mcanouil/quarto-letter) extension, but needed
something that follows DIN 5008.

## 📄 License

[MIT](LICENSE.md)
