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

## Custom Font
Using a custom font is possible via YAML options. This requires the font files to be in the same directory, as the *.qmd file.

Supposing the font files are called 
- "roboto-latin-regular.ttf", 
- "roboto-latin-italic.ttf", 
- "roboto-latin-700.ttf" (for bold...) and 
- "roboto-latin-700italic.ttf" (for bold-italic),
add these options at the end of the YAML section:

```
---
mainfont: roboto # mainfont changes the font for the most parts of the letter
mainfontoptions:
- Extension=.ttf
- UprightFont=*-latin-regular
- BoldFont=*-latin-700
- ItalicFont=*-latin-italic
- BoldItalicFont=*-latin-700italic
sansfont: roboto # sansfont changes the font for the back-address line in the address field
sansfontoptions:
- Extension=.ttf
- UprightFont=*-latin-regular
- BoldFont=*-latin-700
- ItalicFont=*-latin-italic
- BoldItalicFont=*-latin-700italic
---
```

## Credits

I got inspired by Mickaël Canouil's
[quarto-letter](https://github.com/mcanouil/quarto-letter) extension, but needed
something that adheres to DIN 5008.
