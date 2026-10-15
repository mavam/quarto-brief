# Letter geometry audit

The `brief-typst` format targets **Form B**, using the published dimensions
below. This is not a certification of conformity with DIN 5008:2020. The full
normative text has not been checked.

## Coordinate system and zones

Coordinates are millimetres from the physical top-left corner of A4 paper
(210 × 297 mm). A zone's top is not a text baseline.

| Region | Left | Top | Width | Height |
| --- | ---: | ---: | ---: | ---: |
| Outer address window | 20 | 45 | 85 | 45 |
| Return-address text zone | 25 | 45 | 80 | 5 |
| Additional/postal-information text zone | 25 | 50 | 80 | 12.7 |
| Recipient text zone | 25 | 62.7 | 80 | 27.3 |

The text inset is 5 mm inside the window. Return-address and recipient text
therefore align with the reference row and body at **25 mm**, not 20 mm.
The body uses a 20 mm right margin, leaving 165 mm of text width.

The first-page fold marks are **105 and 210 mm from the top**. The punch mark
is at **148.5 mm**. Mark length, stroke, and horizontal offset are visual
choices; their vertical coordinates are independent of the letter contents.

Form A has a 27 mm letterhead instead of 45 mm and different fold positions
(87 and 192 mm). It is not implemented as a selectable variant. A Form A
illustration corroborates the shared horizontal inset only; it does not change
the Form B vertical geometry.

## Text placement within the zones

The implementation derives the recipient start and available size from the
zone dimensions. The published dimensions define zones; the baselines below
are typographic choices within those zones.

- The return-address baseline is at 49 mm: one millimetre above the bottom of
  its 45–50 mm zone. Its underline uses a 1 pt offset. These are typography
  choices; the zone boundary is the published dimension.
- The contact block uses 8 pt type on a 13 pt baseline grid. Its last baseline
  shares that 49 mm baseline, so extra line spacing expands the block upward.
- The first recipient baseline is one line pitch below the 62.7 mm zone top.
  Pitch is the smaller of 1.24 × body font size and (27.3 − 1.5) / 6 mm.
  This reserves six baseline slots and 1.5 mm for descenders.
- More than six recipient entries, or wrapping that makes the measured block
  exceed its zone, produces a render error. The six-line PDF fixture checks
  actual glyph bounds, including descenders, at the default 12 pt size.
- The additional/postal-information zone is reserved but currently has no
  separate input field. Long return addresses and unusually large fonts still
  need visual inspection.

PDF tests verify the recipient and return-address glyphs at x = 25 mm, their
zone containment, and the folding/punch coordinates. Text extraction and
rasterization have small measurement tolerances; those tolerances do not
change the dimensions in the template.

## Positions that are not verified standard requirements

These remain explicit layout choices rather than claimed DIN measurements:

- Logo top: 18 mm; logo width: configurable.
- Horizontal reference row: 9.8 mm after the end of the address zone, giving
  y = 99.8 mm. This is not the optional right-hand information block.
- Reference labels/value spacing and subsequent subject, salutation, body,
  closing, and signature spacing.
- Continuation-page top margin: 40 mm.
- Bottom text margins: 25 mm without footer columns, 35 mm with columns.
- Footer top: 266.8 mm; footer and page-number typography.

The reference-row and paragraph-spacing rules require checking against the
full standard before claiming exact compliance. Copying the information-block
diagram's 8.46 mm separation into a different reference-row layout would not
establish compliance.

## Sources and evidence limits

- [German Customs PDF design guidance](https://www.desy.zoll-portal.de/inhalte/pdf-dokumente/):
  published Form A/B zone dimensions, left text edge, and fold positions.
- [Its Form B diagram](https://www.desy.zoll-portal.de/assets/files/PDF-Vorlage_Form-B.pdf):
  useful visual corroboration, not normative text. Its table incorrectly says
  fold distances are measured from the bottom, contradicting both its drawing
  and the web table. Its logo width/height also differs from the web table.
  Those agency-specific logo dimensions are not used here.
- [Wikimedia Form A illustration](https://upload.wikimedia.org/wikipedia/commons/6/64/DIN_5008%2C_Form_A.svg):
  distinguishes the 20 mm window boundary from the 25 mm text edge.
- KOMA-Script's `DIN.lco` letter-class option file served as a layout
  reference. It is not a substitute for the normative DIN text.

## Remaining verification

Before describing the output as fully DIN-compliant:

- Check the intended DIN 5008 edition, especially reference-row and paragraph
  spacing and typography requirements.
- Review limits for long return addresses, oversized fonts, and wrapped
  recipient lines.
- Print at 100% (no fit-to-page scaling), measure the zones, and test the
  actual envelope and folding process.
