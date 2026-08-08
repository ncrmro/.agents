---
name: finance-report
description: Create reconciled monthly and yearly finance reports with Q1-Q4 sections from bank and credit-card statements. Use DuckDB with CSV, OFX, QFX, or PDF records, and render temporary HTML and PDF reports for review.
---

# Finance report

Create a normalized ledger first. Then create one report for each month and one
report for the year. The yearly report MUST contain Q1, Q2, Q3, and Q4 sections.

Read these files when you need more detail:

- `references/ledger-schema.md` — normalization, sign rules, deduplication, and reconciliation
- `references/duckdb.md` — DuckDB tables, views, import rules, and report queries
- `references/report-templates.md` — required monthly and yearly report structures
- `references/rendering.md` — temporary HTML and PDF rendering and review rules

## Do not count payments as spending

A credit-card payment and the matching bank debit are one transfer. They are not
an expense. A transfer between bank accounts is not income or spending.

Statement signs are not consistent. For example, one card issuer can encode a
purchase as a positive value and a payment as a negative value. Determine the
meaning from the transaction type and statement totals before you normalize the
sign.

## Protect financial data

- Work on local files unless the user explicitly approves another system.
- Treat statements and normalized ledgers as sensitive source records.
- Do not put account numbers, email addresses, postal addresses, or full
  transaction descriptions in a summary report.
- Use a stable account label, such as `checking-1` or `card-1`.
- Do not copy personal statement data into this skill.
- Keep raw source files unchanged.

## Use DuckDB for the ledger

Use DuckDB as the main storage and calculation engine. Read
`references/duckdb.md` before you create the database.

Install DuckDB in the default Nix user profile when the command is absent:

```sh
if ! command -v duckdb >/dev/null 2>&1; then
  if ! command -v nix >/dev/null 2>&1; then
    printf '%s\n' 'finance-report: nix is required to install DuckDB.' >&2
    exit 127
  fi

  nix profile add nixpkgs#duckdb
  hash -r
fi

if ! command -v duckdb >/dev/null 2>&1; then
  printf '%s\n' 'finance-report: DuckDB is installed but is not on PATH.' >&2
  exit 127
fi

duckdb --version
```

Do not use `sudo`. Do not install DuckDB when `command -v duckdb` succeeds.
After an installation, tell the user to run `rehash` in each existing terminal.
Do not replace DuckDB with spreadsheet formulas for the canonical ledger.

## Workflow

### 1. Inventory the sources

List each source file. Record its institution, account label, statement period,
format, and currency. Read the period from the statement content when possible.
Do not trust the filename alone.

Create a coverage table before you calculate totals. The table MUST show every
account and every month in scope. Mark each cell as `complete`, `partial`,
`missing`, or `overlap`.

Use the calendar year unless the user specifies a fiscal year.

### 2. Extract transactions

Use this order:

1. Prefer OFX, QFX, or CSV data.
2. Use a statement PDF to confirm balances and totals.
3. Extract tables from a PDF only when structured transaction data is absent.
4. Use OCR only when the PDF has no usable text layer.

For PDF extraction, use the available source-ingest workflow when it is present.
Keep a source-page reference for each extracted balance or transaction.

Do not use shell text splitting for CSV files. Use a CSV parser because quoted
descriptions can contain commas.

### 3. Normalize the ledger

Follow `references/ledger-schema.md`.

Store the normalized rows in DuckDB. Use `DECIMAL`, `DATE`, and constrained text
values. Do not store money as `FLOAT`, `REAL`, or `DOUBLE`.

Classify each row as one of:

- `expense`
- `income`
- `transfer`
- `refund`
- `fee`
- `interest`
- `adjustment`
- `unknown`

Preserve the raw type, raw category, raw amount, and currency. Use decimal
arithmetic for money. Do not use binary floating-point arithmetic.

Use the posted or clearing date for monthly reports. Preserve the transaction
date for audit work.

### 4. Remove duplicates and match transfers

Prefer a provider transaction ID. If no ID exists, use a deterministic key that
contains the account label, posted date, normalized description, amount,
currency, and source reference.

Do not remove two same-day purchases only because their visible fields match.
Mark an uncertain duplicate for review.

Match a card payment to a bank debit by amount, currency, account pair, and a
reasonable date window. Exclude both sides from income and expense totals. Keep
both rows in the ledger.

### 5. Reconcile before reporting

For each account and statement period, compare:

- transaction totals with the statement activity totals;
- opening balance plus signed activity with closing balance;
- payment, fee, interest, and credit totals with their statement totals.

Record each difference. A difference MUST be zero before the report can claim
`reconciled`.

If the source has no balance or summary totals, mark the result as
`transaction-complete, balance-unverified`.

### 6. Create monthly reports

Create one `YYYY-MM-finance-report.md` file for each month in scope. Use the
monthly template.

The report MUST separate spending, income, refunds, fees, interest, and
transfers. It MUST state its coverage and reconciliation status.

Do not expose every transaction by default. Include a short review queue for
unknown categories, unmatched transfers, possible duplicates, and unusual
amounts.

### 7. Create the yearly report

Create one `YYYY-finance-report.md` file after the monthly reports exist. Derive
its totals from DuckDB views over the normalized ledger. Do not add rounded
display values.

The report MUST contain:

- a Q1 through Q4 table;
- one section for each quarter;
- a January through December table;
- annual category and account summaries;
- coverage and reconciliation status;
- a review queue.

Mark a quarter as `partial` when any account-month is partial or missing. Mark
the year as `partial` until all required account-months are complete.

### 8. Verify the output

The following equations MUST hold:

- annual amount = sum of the four quarter amounts;
- each quarter amount = sum of its three monthly amounts;
- category totals = report total for the same measure;
- account totals = report total for the same measure;
- transfers do not change net income or total spending.

Report discrepancies. Do not force a balancing adjustment without a source
record.

### 9. Render temporary review files

Keep the Markdown report as the canonical report. Render temporary HTML and PDF
copies after all verification checks pass.

From the finance-report skill directory, run:

```sh
scripts/render-report.sh PATH/TO/REPORT.md
```

The script creates a private temporary directory. It writes a self-contained
HTML file and a PDF file. Return both paths to the user.

Read `references/rendering.md` before you publish, copy, or delete a rendered
file.

## Quick diagnostics

| Symptom | Cause | Fix |
| --- | --- | --- |
| Spending is too low after a card payment | The source uses a negative payment value | Classify by type before you apply sign rules |
| Income is too high | A transfer or card payment was classified as income | Match both transfer sides and exclude them from income |
| One month has duplicate activity | Export files overlap or a statement row was imported twice | Compare provider IDs and source periods |
| Quarter totals do not match the year | The yearly report used rounded monthly display values | Aggregate unrounded ledger amounts |
| A PDF total differs from extracted rows | OCR or table extraction lost a row or sign | Check the statement summary and source pages |
| A complete year has fewer than 12 months | Coverage was inferred from available files | Build the account-month coverage table first |
| Money totals differ by a cent | Money was stored as a floating-point value | Cast source values to `DECIMAL` before aggregation |
| DuckDB is not available | The Nix profile does not contain DuckDB | Run the guarded Nix profile installation |
| DuckDB is installed but is not on `PATH` | The Nix profile binary directory is absent from `PATH` | Fix `PATH`, run `rehash`, and check `command -v duckdb` |
| HTML renders but PDF generation fails | WeasyPrint is absent or reports a font or CSS error | Install WeasyPrint and run the renderer again |
| The HTML report has no styling | The renderer did not embed the CSS file | Use `scripts/render-report.sh`; do not call Pandoc without `--embed-resources` |

## Completion criteria

- Raw statements MUST remain unchanged.
- Every source row MUST have a source reference.
- Every report MUST state its coverage and reconciliation status.
- The yearly report MUST show all four quarters, including empty or missing
  quarters.
- Unknown or uncertain classifications MUST remain visible.
- Reports MUST NOT present tax, legal, or investment advice as fact.
- Temporary HTML and PDF reports MUST match the verified Markdown report.
- Temporary reports MUST use private file permissions.
