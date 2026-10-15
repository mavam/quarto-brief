# 📮 Brief — DIN 5008 compliant letters with Quarto

This quarto extension provides a letter template that adheres to the German [DIN
5008](https://de.wikipedia.org/wiki/DIN_5008) requirements, based on the
`scrlttr2` LaTeX document class.

An experimental `brief-typst` format renders the same frontmatter with
[Typst](https://typst.app) instead of LaTeX. See [Typst format](#-typst-format).

## 🚀 Installation

Install [Quarto](https://quarto.org/docs/get-started/) and a TeX distribution
such as [TinyTeX](https://quarto.org/docs/output-formats/pdf-engine.html#tinytex),
then create a letter from the template:

```sh
quarto use template mavam/quarto-brief
```

Adapt the generated `template.qmd` as needed.

## ⚙️ Format options

The sample [template.qmd](template.qmd) demonstrates all available frontmatter
knobs. Many options are directly lifted from the `scrlttr2` class.

### 🗂️ Frontmatter overview

- `author[].name`: sender name shown in the letter head and signature block.
- `author[].email`: activates and fills the “E-Mail” line in the letter head.
- `author[].phone`: activates and fills the telephone line.
- `author[].url`: displays a sender website if provided.
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
- `subject`: bolded subject line before the body text.
- `opening`: greeting that precedes the main letter text.
- `closing`: complimentary close placed before the signature block.
- `ps`: optional postscript appended after the closing.
- `encl[]`: list of enclosures printed at the end of the letter.
- `cc[]`: carbon copy recipients rendered after enclosures.
- `fontsize`: overrides the document base font size (10pt, 11pt, 12pt, …).
- `backaddress`: return-address line above the recipient window (Typst only).
- `letterhead_logo`: logo image at the top right of the first page (Typst only).
- `letterhead_logo_width`: logo width as a Typst length such as 38mm (Typst only).
- `letterhead_background`: Typst file or image drawn behind the first page,
  anchored at the top-left page corner; `false` turns it off (Typst only).
- `footer_columns[][]`: footer columns on every page, each a list of lines
  (Typst only).
- `text_color`: main text color as a hex value such as #0E1017 (Typst only).
- `muted_color`: color of the contact block, return address, and footer; when
  set, also colors the reference-row labels (Typst only).
- `reference_label_font`: font family for the reference-row labels; values keep
  the main font (Typst only).
- `reference_label_size`: reference-row label size as a Typst length such as
  7.5pt; defaults to 0.73em (Typst only).

### ✏️ Setting the font size

The default font size is 12pt. To specify a different size for the document, use
the YAML option 'fontsize'

```yaml
---
fontsize: 11pt
---
```

Any TeX-compatible unit should work, like e.g. `ex`, `in` or `mm`. However, to
avoid layout breaks, it is recommended to use one of the most common sizes
`10pt`, `11pt` or `12pt`.

### Customize fonts

You can adjust fonts by adjusting Quarto's [PDF font
options](https://quarto.org/docs/reference/formats/pdf.html#fonts).

To use a different font, e.g.
[Roboto](https://fonts.google.com/specimen/Roboto), download and unpack the font
archive to get the TTF files. We use these in the example below:

- `Roboto-Bold.ttf`
- `Roboto-BoldItalic.ttf`
- `Roboto-Italic.ttf`
- `Roboto-Regular.ttf`

Then adjust the frontmatter as follows:

```yaml
---
# Used for most parts of the letter.
mainfont: Roboto
mainfontoptions:
- Extension=.ttf
- UprightFont=*-Regular
- BoldFont=*-Bold
- ItalicFont=*-Italic
- BoldItalicFont=*-BoldItalic
# Used for back-address and address field.
sansfont: Roboto
sansfontoptions:
- Extension=.ttf
- UprightFont=*-Regular
- BoldFont=*-Bold
- ItalicFont=*-Italic
- BoldItalicFont=*-BoldItalic
---
```

For more involved letters, you may want to consider setting `monofont` and
`mathfont` and their respective options.

## 🧪 Typst format

The `brief-typst` format needs only Quarto, which bundles Typst. No TeX
installation is required:

```yaml
---
format: brief-typst
---
```

It supports all frontmatter fields above. The first page uses Form B zones:
the outer address window starts 20 mm from the left edge, with a 5 mm text
inset. Return-address, recipient, reference-row, and body text align at 25 mm.
The recipient zone spans 62.7–90 mm from the top; fold and punch marks appear
on the left edge. Addresses support up to six lines and must fit the zone.
The [geometry audit](docs/geometry.md) distinguishes published zone dimensions
from typographic choices and records the remaining conformity checks. The
sender contact block is right-aligned with its last line on the
return-address baseline. Pages after the first repeat the subject and date in a
small header, and multi-page letters show page numbers.

Branding stays out of the extension. Set `letterhead_logo`, `backaddress`,
`footer_columns`, `text_color`, `muted_color`, `reference_label_font`,
`reference_label_size`, and `letterhead_background` per letter or in a shared
`_metadata.yml`. Fonts use Quarto's `mainfont` and `font-paths` options:

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

The [examples](examples) directory contains a generic letter and a fictional
company letterhead that shares its settings through `_metadata.yml`.

Frontmatter values are Markdown. Escape characters that Markdown interprets,
such as a leading `@` (citation) or `<tag>` (raw HTML).

`fontsize` takes Typst lengths such as `11pt` or `4mm`; TeX-only units such as
`ex` don't work. The Typst layout uses published Form B dimensions but hasn't
been verified against the full DIN 5008:2020 standard. The format has been
tested with Quarto 1.10 and its bundled Typst 0.15; older Quarto releases may lack Typst
features it uses.

## 🙏 Credits

I got inspired by Mickaël Canouil's
[quarto-letter](https://github.com/mcanouil/quarto-letter) extension, but needed
something that adheres to DIN 5008.

## 📄 License

[MIT](LICENSE.md)
