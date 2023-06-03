# Brief — DIN 5008 compliant letters with Quarto

This quarto extension provides a letter template that adheres to the German [DIN
5008](https://de.wikipedia.org/wiki/DIN_5008) requirements, based on the
`scrlttr2` LaTeX document class.

## Usage

Install the extension and example qmd file as follows:

```bash
quarto use template mavam/quarto-brief
```

Then adapt the example as you see fit.

## Format Options

The sample [template.qmd](template.qmd) demonstrates all available tuning knobs.
Many options are directly lifted from the `scrlttr2` class.

### Customize Fonts

You can adjust fonts by adjusting Quarto's [PDF font
options](https://quarto.org/docs/reference/formats/pdf.html#fonts).

To use a different font, say [Roboto](https://fonts.google.com/specimen/Roboto),
downloading the font archive and unpack to get the TTF files. We use these
below:

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

## Credits

I got inspired by Mickaël Canouil's
[quarto-letter](https://github.com/mcanouil/quarto-letter) extension, but needed
something that adheres to DIN 5008.
