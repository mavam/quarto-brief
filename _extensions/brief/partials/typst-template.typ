// quarto-brief: Typst letter layout.
//
// Form B zone dimensions follow the published dimensioned references in
// docs/geometry.md. Window boundaries are distinct from text coordinates.
// Typography and optional furniture positions below are layout choices, not
// DIN-prescribed baselines. Coordinates are measured from the page's top left.

#let brief-window = (
  left: 20mm, top: 45mm, width: 85mm, inset: 5mm,
  return-height: 5mm, additional-height: 12.7mm, recipient-height: 27.3mm,
)
#let brief-address = (
  left: brief-window.left + brief-window.inset,
  width: brief-window.width - brief-window.inset,
  top: brief-window.top + brief-window.return-height + brief-window.additional-height,
  height: brief-window.recipient-height,
)
// Typography choice: leave 1 mm beneath the return-address baseline.
#let brief-return-baseline = brief-window.top + brief-window.return-height - 1mm
//
// NOTE: This file is a Pandoc template partial. A literal dollar sign must be
// written as two dollar signs.

#let brief-geometry = (
  margin: (left: 25mm, right: 20mm, top: 40mm),
  bottom: 25mm,
  bottom-with-footer: 35mm,
  window: brief-window,
  address: brief-address,
  backaddress-baseline: brief-return-baseline,
  contact-baseline: brief-return-baseline,
  // Design choice for our horizontal reference-row layout: 9.8 mm below
  // the address zone. Not a normative DIN baseline or an information block.
  refline-top: brief-address.top + brief-address.height + 9.8mm,
  // Letterhead logo, aligned to the right text edge.
  logo-top: 18mm,
  // Top of the footer block.
  footer-top: 266.8mm,
  // Fold marks (form B) and punch mark on the left page edge.
  marks: (hpos: 3.5mm, fold: (105mm, 210mm), fold-length: 2mm, punch: 148.5mm, punch-length: 4mm),
)

#let brief-labels = (
  de: (
    yourmail: "Ihr Schreiben vom",
    yourref: "Ihr Zeichen",
    myref: "Unser Zeichen",
    customer: "Kundennummer",
    invoice: "Rechnungsnummer",
    date: "Datum",
    encl: ("Anlage", "Anlagen"),
    cc: "Kopie an",
    page: (n, total) => [Seite #n von #total],
  ),
  en: (
    yourmail: "Your letter of",
    yourref: "Your reference",
    myref: "Our reference",
    customer: "Customer number",
    invoice: "Invoice number",
    date: "Date",
    encl: ("Enclosure", "Enclosures"),
    cc: "Copy to",
    page: (n, total) => [Page #n of #total],
  ),
)

// Converts Pandoc-generated content back to a plain string, for values that
// Typst needs as strings (file paths, colors).
#let brief-to-string(value) = {
  if value == none {
    none
  } else if type(value) == str {
    value
  } else if type(value) == content {
    if value.has("text") {
      value.text
    } else if value.has("children") {
      value.children.map(brief-to-string).filter(x => x != none).join("")
    } else if value.has("body") {
      brief-to-string(value.body)
    } else if value == [ ] {
      " "
    } else {
      ""
    }
  } else {
    str(value)
  }
}

#let brief-color(value, fallback) = {
  if value == none { return fallback }
  if type(value) == color { return value }
  rgb(brief-to-string(value).trim())
}

// Sets lines on a fixed baseline grid: the block top sits one `pitch` above
// the first baseline and the block bottom is the last baseline. This makes
// absolute positioning independent of the font's ascender and descender.
#let brief-lines(pitch, body) = {
  set text(top-edge: pitch, bottom-edge: "baseline")
  set par(leading: 0pt, spacing: 0pt, justify: false)
  body
}

#let brief-join-lines(lines) = lines.filter(x => x != none).join(linebreak())

// Places content at absolute page coordinates. Must be called from the
// first-page letterhead block, whose origin is the top-left text corner.
#let brief-at(x, y, body) = place(
  top + left,
  dx: x - brief-geometry.margin.left,
  dy: y - brief-geometry.margin.top,
  body,
)

#let brief(
  lang: "de",
  region: none,
  font: none,
  fontsize: 12pt,
  text-color: none,
  muted-color: none,
  reference-label-font: none,
  reference-label-size: 0.73em,
  sender: (:),
  backaddress: auto,
  logo: none,
  logo-width: 40mm,
  background: none,
  recipient: (),
  date: none,
  date-label: none,
  location: none,
  location-label: none,
  references: (),
  subject: none,
  opening: none,
  closing: none,
  signature: none,
  ps: none,
  encl: (),
  cc: (),
  footer-columns: (),
  doc,
) = {
  let g = brief-geometry
  let ink = brief-color(text-color, black)
  let muted = brief-color(muted-color, luma(80))
  let labels = brief-labels.at(lang, default: brief-labels.en)
  let label-for(key, custom) = if custom != none { custom } else { labels.at(key) }
  let sender-name = sender.at("name", default: none)

  // Address lines of the sender, in German order.
  let sender-address = {
    let postal = (sender.at("postal-code", default: none), sender.at("city", default: none))
      .filter(x => x != none)
    (
      sender.at("street", default: none),
      if postal.len() > 0 { postal.join(" ") },
      sender.at("country", default: none),
    ).filter(x => x != none)
  }

  let backaddress = if backaddress == auto {
    if sender-address.len() > 0 {
      ((sender-name,) + sender-address).filter(x => x != none).join(", ")
    }
  } else {
    backaddress
  }

  set document(
    author: if sender-name != none { brief-to-string(sender-name) } else { () },
    title: if subject != none { brief-to-string(subject) } else { none },
  )
  set text(lang: lang, size: fontsize, fill: ink)
  set text(region: region) if region != none
  set text(font: font) if font != none
  set par(justify: true, leading: 0.5em, spacing: 1.12em)
  show link: set text(fill: ink)

  // Footer block with free-form columns spread across the text width.
  let footer-block = if footer-columns.len() > 0 {
    let n = footer-columns.len()
    let columns = range(n).map(i => if i < n - 1 { (auto, 1fr) } else { (auto,) }).flatten()
    let cells = footer-columns.enumerate().map(((i, column)) => {
      let cell = brief-join-lines(column)
      if i < n - 1 { (cell, []) } else { (cell,) }
    }).flatten()
    brief-lines(9.5pt, text(size: 7.5pt, fill: muted, grid(columns: columns, ..cells)))
  }

  let has-footer = footer-block != none
  let bottom-margin = if has-footer { g.bottom-with-footer } else { g.bottom }

  set page(
    paper: "a4",
    margin: (left: g.margin.left, right: g.margin.right, top: g.margin.top, bottom: bottom-margin),
    header-ascent: 8mm,
    header: context {
      if here().page() > 1 {
        set text(size: 8pt, fill: muted)
        set par(justify: false)
        let left-part = if subject != none { subject } else if recipient.len() > 0 { recipient.first() }
        grid(columns: (1fr, auto), column-gutter: 5mm, left-part, date)
      }
    },
    footer-descent: 0pt,
    footer: context {
      let page-number = here().page()
      let total = counter(page).final().first()
      if has-footer {
        // The footer area starts at the bottom margin; move to the footer top.
        v(g.footer-top - (297mm - bottom-margin))
        footer-block
      }
      if total > 1 {
        set text(size: 7.5pt, fill: muted)
        v(if has-footer { 2mm } else { 6mm })
        align(right, (labels.page)(page-number, total))
      }
    },
    background: context {
      if here().page() == 1 {
        // Optional first-page decoration, anchored at the top-left page
        // corner: a Typst file (included as content) or an image.
        if background != none {
          let path = brief-to-string(background)
          place(top + left, if path.ends-with(".typ") { include path } else { image(path) })
        }
        let m = g.marks
        let mark(y, length) = place(
          top + left,
          dx: m.hpos,
          dy: y,
          line(length: length, stroke: 0.25pt + ink),
        )
        for y in m.fold { mark(y, m.fold-length) }
        mark(m.punch, m.punch-length)
      }
    },
  )

  // First-page letterhead. The block reserves the space down to the reference
  // line; its children use absolute page coordinates.
  block(width: 100%, height: g.refline-top - g.margin.top, above: 0pt, below: 0pt, {
    if logo != none {
      brief-at(g.margin.left, g.logo-top, box(
        width: 210mm - g.margin.left - g.margin.right,
        align(right, image(brief-to-string(logo), width: logo-width, alt: "Logo")),
      ))
    }

    // Sender contact block, right-aligned. Its last baseline matches the
    // return-address baseline.
    let contact = (
      if sender-name != none { text(fill: ink, weight: "semibold", sender-name) },
      ..sender-address,
      sender.at("phone", default: none),
      sender.at("email", default: none),
      sender.at("url", default: none),
    ).filter(x => x != none)
    if contact.len() > 0 {
      brief-at(g.margin.left, 0mm, box(
        width: 210mm - g.margin.left - g.margin.right,
        height: g.contact-baseline,
        align(right + bottom, brief-lines(13pt, text(size: 8pt, fill: muted, brief-join-lines(contact)))),
      ))
    }

    if backaddress != none {
      brief-at(g.address.left, 0mm, box(
        width: g.address.width,
        height: g.backaddress-baseline,
        align(left + bottom, brief-lines(7pt, text(
          size: 7pt,
          fill: muted,
          underline(offset: 1pt, stroke: 0.5pt + muted, evade: false, backaddress),
        ))),
      ))
    }

    if recipient.len() > 0 {
      assert(recipient.len() <= 6, message: "The recipient address supports at most six lines.")
      // Six baseline slots within the 27.3 mm zone, with 1.5 mm reserved for
      // descenders. Typography may vary; the zone boundaries do not.
      let pitch = calc.min(fontsize * 1.24, (g.address.height - 1.5mm) / 6)
      let address-block = box(
        width: g.address.width,
        brief-lines(pitch, brief-join-lines(recipient)),
      )
      context {
        assert(measure(address-block).height <= g.address.height,
          message: "The recipient address exceeds its 27.3 mm zone; shorten or reformat it.")
        brief-at(g.address.left, g.address.top, address-block)
      }
    }
  })

  // Reference line. Without reference fields, only place and date appear,
  // right-aligned.
  let date-value = if location != none and location-label == none and date != none {
    [#location, #date]
  } else if location != none and location-label == none {
    location
  } else {
    date
  }
  let fields = references.map(r => (label-for(r.key, r.label), r.value))
  if location != none and location-label != none { fields.push((location-label, location)) }
  let labeled = fields.len() > 0 or date-label != none
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, {
    set par(justify: false)
    // Each cell sets a small label above its value on a fixed baseline grid.
    let cell(label, value) = {
      set text(top-edge: 0pt, bottom-edge: "baseline")
      set par(leading: 0pt, spacing: 0pt)
      // The fixed top edge keeps label and value baselines independent of
      // the label font and size.
      {
        set text(font: reference-label-font) if reference-label-font != none
        set text(fill: muted) if muted-color != none
        text(size: reference-label-size, top-edge: 3.4mm, label)
      }
      linebreak()
      text(top-edge: 4.9mm, value)
    }
    if labeled {
      let cells = fields.map(((label, value)) => cell(label, value))
      if date-value != none { cells.push(cell(label-for("date", date-label), date-value)) }
      // Spread the cells across the line; the last cell ends at the right edge.
      let row = grid(columns: (auto,) * cells.len(), column-gutter: 1fr, ..cells)
      if fields.len() == 0 { align(right, row) } else { row }
    } else if date-value != none {
      // Keep the date on the same baseline as a labeled value.
      set text(top-edge: 3.4mm + 4.9mm, bottom-edge: "baseline")
      align(right, date-value)
    }
  })

  // Vertical rhythm after the reference line. Distances are baseline to
  // baseline; 0.73em approximates the cap height that starts the next line.
  v(9.9mm - 0.73em)
  if subject != none {
    block(above: 0pt, below: 0pt, text(weight: "bold", subject))
    v(14.3mm - 0.73em)
  }
  if opening != none {
    block(above: 0pt, below: 0pt, opening)
    v(9.6mm - 0.73em)
  }

  doc

  // Closing, signature, postscript, enclosures, and copies.
  if closing != none or sender-name != none {
    block(above: 1.75em, breakable: false, {
      set par(justify: false)
      if closing != none { closing; parbreak() }
      if signature != none {
        v(2mm)
        image(brief-to-string(signature), height: 15mm, alt: "Signature")
        v(1mm)
      } else if closing != none {
        v(8.5mm)
      }
      if sender-name != none { sender-name }
    })
  }
  if ps != none {
    block(above: 2em, ps)
  }
  if encl.len() > 0 {
    block(above: 2em, breakable: false, {
      set par(justify: false)
      text(weight: "bold", labels.encl.at(if encl.len() == 1 { 0 } else { 1 }))
      linebreak()
      brief-join-lines(encl)
    })
  }
  if cc.len() > 0 {
    block(above: 1.5em, breakable: false, {
      set par(justify: false)
      text(weight: "bold", labels.cc)
      linebreak()
      brief-join-lines(cc)
    })
  }
}
