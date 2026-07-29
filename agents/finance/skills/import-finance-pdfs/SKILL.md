---
name: import-finance-pdfs
description: Import personal financial PDF statements and records with Docling as dated Markdown files. Use when adding a bank, credit-card, investment, mortgage, tax, payroll, or other finance PDF to the personal finance archive.
---

# Import finance PDFs

Convert each PDF into one Markdown document under:

```text
~/notes/docs/personal/finances/YYYY-MM-DD-name.md
```

The date is the statement or document date, not the import date. Use a concise
lowercase kebab-case name such as `apple-card-statement`.

## Import

Run from this skill directory:

```bash
devenv shell -- scripts/import-finance-pdf \
  "/path/to/statement.pdf" \
  "2026-04-30-apple-card-statement"
```

The script refuses invalid names and existing destinations. It converts
locally, preserves tables, writes the result with private permissions, and
prints the destination path.

Use `--ocr` before the source path only for a scanned PDF without a usable text
layer:

```bash
devenv shell -- scripts/import-finance-pdf \
  --ocr "/path/to/scan.pdf" "2026-04-30-name"
```

## Rules

- Keep original financial PDFs outside the notes repository.
- Never send financial documents to a remote conversion or model service.
- Never overwrite an existing export; compare the documents and choose an
  explicit revision name when both must be retained.
- Treat Markdown as an extraction. Verify balances, totals, dates, and
  transaction details against the original PDF before relying on them.
- After import, report the source, destination, conversion mode, and whether
  table output is present. Do not echo private financial values into chat.
