# ✉️ Brief — DIN 5008 compliant letters with Quarto

This quarto extension provides a letter template that adheres to the German [DIN
5008](https://de.wikipedia.org/wiki/DIN_5008) requirements, based on the
`scrlttr2` LaTeX document class.

## 🚀 Usage

Install the extension and example qmd file as follows:

```bash
quarto use template mavam/quarto-brief
```

Then adapt the example as you see fit.

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

## 🙏 Credits

I got inspired by Mickaël Canouil's
[quarto-letter](https://github.com/mcanouil/quarto-letter) extension, but needed
something that adheres to DIN 5008.
