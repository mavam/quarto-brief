# Agent guidelines

This repository is a Quarto extension for DIN 5008-compliant German letters
based on the `scrlttr2` LaTeX class.

## Project layout

```text
_extensions/brief/
├── _extension.yml
├── _schema.yml
├── _snippets.json
├── header.tex
├── partials/
│   ├── _address.tex
│   ├── before-body.tex
│   ├── after-body.tex
│   └── template.tex
template.qmd
README.md
```

## Keep frontmatter fields in sync

Keep every supported frontmatter field aligned across these files:

1. `_extensions/brief/partials/before-body.tex` and `after-body.tex`
   - Canonical source.
   - A field only works if these templates handle it.
2. `_extensions/brief/_schema.yml`
   - Quarto Wizard completion and validation.
3. `README.md`
   - User-facing frontmatter reference.

Update `_extensions/brief/_snippets.json` when a field belongs in the common
insertion snippet. Snippets are representative, not exhaustive.

Also keep `template.qmd` up to date. It should demonstrate every supported
field so rendering catches regressions.

CI runs `scripts/check-sync.sh` to compare the field sets across the templates,
schema, and README. It also validates `_snippets.json` references.

Run this before pushing:

```bash
bash scripts/check-sync.sh
```

## Checklist for field changes

When you add, rename, or remove a field:

1. Update the Pandoc template variable in `before-body.tex` or `after-body.tex`.
2. Update `_extensions/brief/_schema.yml`.
3. Update `_extensions/brief/_snippets.json` if the field belongs in the common snippet.
4. Update `README.md`.
5. Update `template.qmd`.
6. Render the example:

   ```bash
   quarto render template.qmd
   ```

## Schema conventions

In `_extensions/brief/_schema.yml`:

- Put fields under `formats.brief-pdf.<field>`.
- Use `type: string` for scalar values.
- Use `type: array` with `items.type: string` for lists.
- For file paths, add `completion.type: file` and the allowed extensions.
- Keep the file valid against the Quarto Wizard extension schema:
  `https://m.canouil.dev/quarto-wizard/assets/schema/v1/extension-schema.json`

References:

- Schema: <https://m.canouil.dev/quarto-wizard/reference/schema-specification.html>
- Snippets: <https://m.canouil.dev/quarto-wizard/reference/snippet-specification.html>

## Snippet conventions

In `_extensions/brief/_snippets.json`:

- Use standard VS Code snippet JSON.
- Use tab stops like `$1`, `$2`, and so on.
- Keep snippets focused on common fields, not every option.

## LaTeX notes

- `\setkomavar{name}[label]{value}` sets a KOMA-Script variable. The optional
  label overrides the printed caption.
- `\KOMAoptions{key=value}` enables options such as `fromphone=true`.
- Author metadata such as `name`, `email`, `phone`, `url`, and `affiliations`
  comes from Quarto's built-in schema and is handled in `before-body.tex`.

## Style

- Use `snake_case` for YAML keys.
- Write `_schema.yml` and `README.md` descriptions in English.
- Keep the example content in `template.qmd` in German.
- Use Conventional Commits such as `feat:`, `fix:`, and `docs:`.
