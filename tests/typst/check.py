#!/usr/bin/env python3
"""Inspect rendered brief-typst PDFs.

Usage: check.py <output-dir>

Expects the PDFs that scripts/test-typst.sh renders into <output-dir>. Uses
pdftotext, pdftohtml, and pdffonts from Poppler. Coordinates are in millimeters from the
top-left page corner.
"""

import html
import re
import subprocess
import sys
import tempfile
from pathlib import Path

PT_TO_MM = 25.4 / 72
BODY_BOTTOM_WITH_FOOTER = 297 - 35  # Bottom text edge when footer columns are set.
FOOTER_TOP = 266.0
TEXT_TOP = 40.0

failures = []


def check(condition, message):
    if not condition:
        failures.append(message)


def pages(pdf):
    """Returns a list of pages, each a list of (x0, y0, x1, y1, word)."""
    out = subprocess.run(
        ["pdftotext", "-bbox", str(pdf), "-"], check=True, capture_output=True, text=True
    ).stdout
    result = []
    for page in re.split(r"<page ", out)[1:]:
        words = []
        for m in re.finditer(
            r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</word>',
            page,
        ):
            x0, y0, x1, y1 = (float(v) * PT_TO_MM for v in m.groups()[:4])
            words.append((x0, y0, x1, y1, html.unescape(m.group(5))))
        result.append(words)
    return result


def text(pdf):
    out = subprocess.run(
        ["pdftotext", str(pdf), "-"], check=True, capture_output=True, text=True
    ).stdout
    return " ".join(out.split())


class Raster:
    """One rasterized page: RGB (channels=3) or grayscale (channels=1)."""

    def __init__(self, path, dpi):
        data = path.read_bytes()
        magic, dims, _, pixels = data.split(b"\n", 3)
        self.channels = 3 if magic == b"P6" else 1
        self.width, self.height = map(int, dims.split())
        self.pixels = pixels
        self.mm = 25.4 / dpi

    def pixel(self, x, y):
        i = (y * self.width + x) * self.channels
        return tuple(self.pixels[i : i + self.channels])

    def coords(self):
        for y in range(self.height):
            for x in range(self.width):
                yield x, y


def rasters(pdf, dpi=60, gray=False):
    """Rasterizes all pages of a PDF."""
    with tempfile.TemporaryDirectory() as tmp:
        args = ["pdftoppm", "-r", str(dpi)] + (["-gray"] if gray else []) + [str(pdf), f"{tmp}/p"]
        subprocess.run(args, check=True)
        return [Raster(path, dpi) for path in sorted(Path(tmp).iterdir())]


def is_red(rgb):
    r, g, b = rgb
    return r > 200 and g < 80 and b < 80


def red_extent(page):
    """Returns the maximum y (mm) of pure-red test decoration, or None."""
    ys = [y for x, y in page.coords() if is_red(page.pixel(x, y))]
    return max(ys) * page.mm if ys else None


def check_blank_band(name, pdf, bottom=17.0):
    """The band above the logo is pure white: no decoration by default."""
    page = rasters(pdf)[0]
    ink = [(x, y) for x, y in page.coords() if y * page.mm < bottom and min(page.pixel(x, y)) < 250]
    check(not ink, f"{name}: unexpected marks in the top {bottom} mm (default must be undecorated)")


def text_fonts(pdf):
    """Maps each first-page text run to its (font family, size, color)."""
    out = subprocess.run(
        ["pdftohtml", "-xml", "-i", "-stdout", "-f", "1", "-l", "1", str(pdf)],
        check=True, capture_output=True, text=True,
    ).stdout
    specs = {
        m.group(1): (re.sub(r"^[A-Z]{6}\+", "", m.group(3)), int(m.group(2)), m.group(4))
        for m in re.finditer(r'<fontspec id="(\d+)" size="(\d+)" family="([^"]+)" color="([^"]+)"/>', out)
    }
    runs = {}
    for m in re.finditer(r'<text [^>]*font="(\d+)">(.*?)</text>', out):
        runs.setdefault(html.unescape(re.sub(r"<[^>]+>", "", m.group(2))).strip(), specs[m.group(1)])
    return runs


def find(words, word):
    return [w for w in words if w[4] == word]


def expect_text(name, pdf, needles):
    content = text(pdf)
    for needle in needles:
        check(needle in content, f"{name}: missing text {needle!r}")
    return content


def expect_absent(name, pdf, needles):
    content = text(pdf)
    for needle in needles:
        check(needle not in content, f"{name}: unexpected text {needle!r}")


def expect_order(name, content, needles):
    positions = [content.find(n) for n in needles]
    check(
        all(p >= 0 for p in positions) and positions == sorted(positions),
        f"{name}: expected order {needles}",
    )


def near(a, b, tolerance=0.6):
    return abs(a - b) <= tolerance


def check_no_footer_overlap(name, doc):
    """Every word sits in the header, the text area, or the footer zone."""
    for number, words in enumerate(doc, start=1):
        footer = [w for w in words if w[1] >= FOOTER_TOP]
        check(footer, f"{name}: page {number} has no footer")
        for x0, y0, x1, y1, word in words:
            in_body = y1 <= BODY_BOTTOM_WITH_FOOTER + 0.5
            in_footer = y0 >= FOOTER_TOP
            check(in_body or in_footer, f"{name}: page {number}: {word!r} overlaps footer zone ({y0:.1f}-{y1:.1f} mm)")
        if number > 1:
            header = [w for w in words if w[3] < TEXT_TOP - 2]
            check(header, f"{name}: page {number} has no running header")
            for x0, y0, x1, y1, word in words:
                check(y1 < TEXT_TOP - 2 or y0 >= TEXT_TOP - 1, f"{name}: page {number}: {word!r} overlaps running header")


def check_fold_marks(pdf):
    """Check physical first-page fold/punch positions, independently of text."""
    page = rasters(pdf, dpi=100)[0]
    ys = [y * page.mm for x, y in page.coords()
          if 3 <= x * page.mm <= 8 and min(page.pixel(x, y)) < 200]
    for expected in (105, 148.5, 210):
        check(any(near(y, expected, 0.35) for y in ys),
              f"marks: missing Form B mark at {expected} mm")
    check(all(any(near(y, expected, 0.35) for expected in (105, 148.5, 210)) for y in ys),
          "marks: unexpected mark outside Form B positions")


def check_six_line(pdf):
    doc = pages(pdf)
    check(len(doc) == 1, "six-line: expected one page")
    words = [w for w in doc[0] if 60 <= w[1] < 95]
    check(words and all(24.9 <= w[0] and w[2] <= 105.1 and 62.7 <= w[1] and w[3] <= 90 for w in words),
          "six-line: glyphs outside recipient zone (25–105 × 62.7–90 mm)")
    lines = {}
    for word in words:
        lines.setdefault(round(word[1], 2), []).append(word)
    check(len(lines) == 6, f"six-line: expected six lines, got {len(lines)}")
    check(all(near(min(w[0] for w in line), 25, 0.1) for line in lines.values()),
          "six-line: address lines do not all align at 25 mm")
    check(any(w[4] == "Hamburg" for w in words), "six-line: last line missing")


def check_company(pdf):
    name = "company"
    backaddress = "Example GmbH · Musterweg 5 · 10115 Berlin"
    check_fold_marks(pdf)
    doc = pages(pdf)
    check(len(doc) == 1, f"{name}: expected 1 page, got {len(doc)}")
    content = expect_text(name, pdf, [
        "Erika Beispiel +49 30 0000001 erika.beispiel@example.com", backaddress,
        "Musterfirma GmbH Max Mustermann Musterstraße 1 12345 Musterstadt",
        "Angebotsnummer", "Q-2026-001", "Datum", "Musterbrief",
        "Sehr geehrter Herr Mustermann,", "Mit freundlichen Grüßen",
        "HRB 000000", "IBAN: DE00 0000 0000 0000 0000 00", "https://example.com",
    ])
    expect_absent(name, pdf, ["Seite 1"])
    expect_order(name, content, ["Angebotsnummer", "Musterbrief", "Sehr geehrter", "Mit freundlichen", "Erika Beispiel Example GmbH"])
    words = doc[0]
    return_words = [w for w in words if w[0] < 105 and 44 <= w[1] < 51]
    check([w[4] for w in return_words] == backaddress.split(),
          f"{name}: return address incomplete or wrapped: {[w[4] for w in return_words]}")
    check(return_words and near(return_words[0][0], 25, 0.1), f"{name}: return address not at 25 mm")
    check(return_words and all(24.9 <= w[0] and w[2] <= 105.1 and 45 <= w[1] and w[3] <= 50 for w in return_words),
          f"{name}: return address outside 25–105 × 45–50 mm zone")
    check(len({round(w[3], 2) for w in return_words}) == 1, f"{name}: return address not on one line")
    email = find(words, "erika.beispiel@example.com")
    if email and return_words:
        check(near(email[0][2], 190), f"{name}: contact block not flush with 190 mm ({email[0][2]:.1f})")
        check(near(email[0][3], return_words[0][3], 0.8), f"{name}: email not on return-address baseline")
    musterfirma = find(words, "Musterfirma")
    check(musterfirma and near(musterfirma[0][0], 25, 0.1), f"{name}: recipient not at 25 mm")
    check(musterfirma and 62.7 <= musterfirma[0][1] < 68, f"{name}: recipient not in window zone")
    address_words = [w for w in words if w[0] < 105 and 60 <= w[1] < 90]
    check(address_words and all(w[0] >= 24.9 and w[2] <= 105.1 and w[1] >= 62.7 and w[3] <= 90 for w in address_words), f"{name}: recipient outside 25–105 × 62.7–90 mm text zone")
    subject = find(words, "Musterbrief")
    check(subject and near(subject[0][0], 25), f"{name}: body not at 25 mm")
    # Typography: only the reference labels use the configured label font, in
    # the muted color. Values, return address, and other text keep the main font.
    fonts = subprocess.run(["pdffonts", str(pdf)], check=True, capture_output=True, text=True).stdout
    check("DejaVuSansMono" in fonts, f"{name}: label font not embedded")
    runs = text_fonts(pdf)
    for label in ("Angebotsnummer", "Datum"):
        family, _, color = runs.get(label, ("", 0, ""))
        check(family == "DejaVuSansMono" and color == "#4a5568",
              f"{name}: label {label!r} not in muted label font ({family}, {color})")
    main = runs.get("Q-2026-001", ("?",))[0]
    check(main != "DejaVuSansMono", f"{name}: reference value uses the label font")
    for value in ("Musterbrief", "Musterfirma GmbH", "Max Mustermann", "Erika Beispiel", "HRB 000000"):
        family = runs.get(value, ("",))[0]
        check(family.startswith(main), f"{name}: {value!r} not in main font ({family})")
    family, _, color = runs.get(backaddress, ("", 0, ""))
    check(family.startswith(main) and color == "#4a5568",
          f"{name}: return address not one muted main-font line ({family}, {color})")
    mono = [run for run, spec in runs.items() if spec[0] == "DejaVuSansMono"]
    check(sorted(mono) == ["Angebotsnummer", "Datum"], f"{name}: label font outside reference labels: {mono}")
    # Label and value baselines stay on the fixed grid regardless of label font.
    labels = [w for w in words if w[4] in ("Angebotsnummer", "Datum") and w[1] < 110]
    values = find(words, "Q-2026-001")
    check(len(labels) == 2 and near(labels[0][1], labels[1][1], 0.05), f"{name}: reference labels not on one line")
    check(values and near(values[0][3], 109.0, 0.3), f"{name}: reference value moved ({values[0][3] if values else None})")
    check_no_footer_overlap(name, doc)


def check_company_plain(default, disabled):
    """The default has no background: it matches an explicitly disabled one."""
    check(pages(default) == pages(disabled), "company: disabling background changes text")
    normal = rasters(default, dpi=100)[0]
    plain = rasters(disabled, dpi=100)[0]
    check(normal.pixels == plain.pixels, "company: default has background decoration")
    check_blank_band("company", default)
    ink = [(x, y) for x, y in normal.coords()
           if x * normal.mm > 191 and y * normal.mm < 90
           and min(normal.pixel(x, y)) < 250]
    check(not ink, "company: unexpected marks down the outer-right margin")


def check_generic(pdf):
    name = "generic"
    check_blank_band(name, pdf)
    doc = pages(pdf)
    content = expect_text(name, pdf, [
        "Erika Beispiel, Foostraße 42, 1337 Barstadt, Bazmanien",
        "https://example.com",
        "Ihre Nummer", "Ihre Mail", "Meine Nummer", "Kunde", "Rechnung", "Datum",
        "1. Januar 2023", "Ort", "Barstadt", "15. Februar 2023", "Betreffzeile",
        "Anlagen Anlage 1 Anlage 2", "Kopie an Waldo Fred",
        "PS: Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    ])
    expect_order(name, content, ["Ihre Nummer", "Ihre Mail", "Meine Nummer", "Kunde", "Rechnung", "Ort", "Datum"])
    expect_absent(name, pdf, ["Barstadt, 15. Februar"])
    expect_order(name, content, ["Mit freundlichem Gruß", "PS:", "Anlagen", "Kopie an"])
    check(len(doc) <= 2, f"{name}: expected at most 2 pages, got {len(doc)}")
    # Without label options, labels keep the main font and the ink color.
    runs = text_fonts(pdf)
    families = {runs[k][0] for k in ("Ihre Nummer", "Datum", "Betreffzeile") if k in runs}
    check(len(families) == 1, f"{name}: reference labels changed font ({families})")
    check(runs.get("Ihre Nummer", (0, 0, ""))[2] == runs.get("Betreffzeile", (0, 0, "?"))[2],
          f"{name}: reference labels changed color")


def check_template(pdf):
    name = "template"
    check_blank_band(name, pdf)
    check_fold_marks(pdf)
    doc = pages(pdf)
    check(len(doc) == 1, f"{name}: expected 1 page, got {len(doc)}")
    content = expect_text(name, pdf, [
        "Erika Beispiel, Foostraße 42, 1337 Barstadt, Bazmanien",
        "erika.beispiel@example.com", "+49 123 4567890",
        "Corge Grault Quuxstraße 314 4711 Garply Xyzzilien",
        "Ihre Nummer", "Ihre Mail", "Meine Nummer", "Kunde", "Rechnung", "Datum",
        "1. Januar 2023", "15. Februar 2023", "Betreffzeile",
        "Sehr geehrte Damen und Herren,", "quarto render template.qmd",
        "Anlagen Anlage 1 Anlage 2",
        "PS: Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    ])
    expect_order(name, content, ["Ihre Nummer", "Ihre Mail", "Meine Nummer", "Kunde", "Rechnung", "Datum"])
    expect_order(name, content, ["Betreffzeile", "Sehr geehrte", "Mit freundlichem Gruß", "PS:", "Anlagen"])
    expect_absent(name, pdf, ["Seite 1", "Kopie an"])
    corge = find(doc[0], "Corge")
    check(corge and near(corge[0][0], 25, 0.1) and 62.7 <= corge[0][1] < 68,
          f"{name}: recipient not at 25 mm in the window zone")


def check_multipage(pdf):
    name = "multipage"
    doc = pages(pdf)
    check(len(doc) >= 2, f"{name}: expected several pages, got {len(doc)}")
    content = expect_text(name, pdf, [
        "Berlin, 1. März 2026", "Mehrseitiger Testbrief", "Erster Punkt", "Verschachtelter Punkt",
        "Anlage Angebot", "Kopie an Buchhaltung Vertrieb",
    ])
    for number in range(1, len(doc) + 1):
        check(f"Seite {number} von {len(doc)}" in content, f"{name}: missing page number {number}")
    check(content.count("HRB 000000") == len(doc), f"{name}: footer not on every page")
    expect_order(name, content, ["Mit freundlichen Grüßen", "Erika Beispiel PS:", "Anlage", "Kopie an"])
    # The closing block stays together on one page.
    last = " ".join(w[4] for w in doc[-1])
    check("Grüßen" in last and "Beispiel" in last, f"{name}: closing block split across pages")
    check_no_footer_overlap(name, doc)
    # The .typ background hook decorates the first page only.
    pages_raster = rasters(pdf)
    extent = red_extent(pages_raster[0])
    check(extent is not None and extent <= 10.5, f"{name}: Typst background missing or outside its 10 mm band ({extent})")
    for number, page in enumerate(pages_raster[1:], start=2):
        check(red_extent(page) is None, f"{name}: background repeated on page {number}")


def check_plain_multipage(pdf):
    name = "plain-multipage"
    doc = pages(pdf)
    check(len(doc) >= 2, f"{name}: expected several pages, got {len(doc)}")
    expect_text(name, pdf, [
        "Jane Doe, 1 Example Road, 12345 Springfield",
        "Long letter without footer", "Sincerely, Jane Doe",
    ])
    for number, words in enumerate(doc, start=1):
        marker = [w for w in words if w[4] == "Page"]
        check(len(marker) == 1, f"{name}: page {number} lacks a page number")
        if marker:
            others = [w for w in words if w[1] < marker[0][1] - 0.1]
            body_bottom = max(w[3] for w in others)
            check(marker[0][1] > body_bottom + 1, f"{name}: page {number}: page number overlaps body text")
        if number > 1:
            check(any(w[3] < TEXT_TOP - 2 for w in words), f"{name}: page {number} has no running header")


def check_minimal(pdf):
    name = "minimal"
    doc = pages(pdf)
    check(len(doc) == 1, f"{name}: expected 1 page, got {len(doc)}")
    expect_text(name, pdf, ["Erika Musterfrau Musterstraße 1 12345 Musterstadt", "Pflichtangaben"])
    expect_absent(name, pdf, ["Seite", "Datum", "Anlage", "Kopie an"])
    words = doc[0]
    check(all(w[1] > 55 for w in words), f"{name}: unexpected letterhead content")
    check_blank_band(name, pdf)


def check_special(pdf):
    name = "special"
    content = expect_text(name, pdf, [
        "Ann O’Neil & Co. #1",
        "Dr. Jane “JJ” Doe_Smith", "c/o 50% Off $ales [B] @ Main",
        "1. Floor, 742 Evergreen Terrace", "- Unit 3 / Rear = Back",
        "Your reference", "Our reference", "Customer number", "Invoice number", "Date",
        "#42_A", "AB-$100", "C-7 ~ 100%", "2026/007", "Springfield, October 15, 2026",
        "Re: “Quotes”, $5 & #hash mail@example.com under star",
        "# $ % & _ { } ~ ^", "Enclosures 1. Contract (2×) Price list #3",
        "Copy to Legal & Compliance",
    ])
    expect_order(name, content, ["Your reference", "Our reference", "Customer number", "Invoice number", "Date"])
    # The image background hook (SVG) draws at the top-left page corner.
    extent = red_extent(rasters(pdf)[0])
    check(extent is not None and extent <= 8.5, f"{name}: image background missing or misplaced ({extent})")


def main():
    out = Path(sys.argv[1])
    checks = {
        "template.pdf": check_template,
        "examples/company/letter.pdf": check_company,
        "examples/generic/letter.pdf": check_generic,
        "tests/typst/multipage.pdf": check_multipage,
        "tests/typst/minimal.pdf": check_minimal,
        "tests/typst/plain-multipage.pdf": check_plain_multipage,
        "tests/typst/special.pdf": check_special,
        "tests/typst/six-line.pdf": check_six_line,
    }
    for relative, function in checks.items():
        pdf = out / relative
        if not pdf.exists():
            failures.append(f"missing {pdf}")
            continue
        function(pdf)
    plain = out / "plain/examples/company/letter.pdf"
    if plain.exists():
        check_company_plain(out / "examples/company/letter.pdf", plain)
    else:
        failures.append(f"missing {plain}")
    if failures:
        print("\n".join(f"FAIL: {f}" for f in failures))
        sys.exit(1)
    print(f"✓ {len(checks) + 1} PDFs passed layout, text, and raster checks.")


if __name__ == "__main__":
    main()
