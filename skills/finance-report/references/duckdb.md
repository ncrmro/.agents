# DuckDB finance ledger

Use one DuckDB database as the canonical derived ledger. Keep source statements
unchanged. Rebuild the database from the sources when normalization rules change.

## Database location

Create the database in a private work directory. Use a stable name such as
`finance.duckdb`. Do not commit it unless the user explicitly approves that
storage policy.

Restrict access when the file system supports POSIX permissions:

```sh
chmod 600 finance.duckdb
```

## Tables

Create typed tables before you import normalized rows. Do not make
`read_csv_auto` the canonical schema.

```sql
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id VARCHAR PRIMARY KEY,
    account_label VARCHAR NOT NULL,
    account_type VARCHAR NOT NULL,
    institution VARCHAR NOT NULL,
    transaction_date DATE,
    posted_date DATE NOT NULL,
    description VARCHAR NOT NULL,
    merchant VARCHAR,
    raw_category VARCHAR,
    category VARCHAR NOT NULL,
    kind VARCHAR NOT NULL,
    expense_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    income_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    transfer_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    refund_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    raw_amount DECIMAL(18,2) NOT NULL,
    currency VARCHAR NOT NULL,
    source_file VARCHAR NOT NULL,
    source_locator VARCHAR NOT NULL,
    statement_start DATE,
    statement_end DATE,
    confidence VARCHAR NOT NULL,
    notes VARCHAR,
    CHECK (kind IN ('expense', 'income', 'transfer', 'refund', 'fee',
                    'interest', 'adjustment', 'unknown')),
    CHECK (account_type IN ('checking', 'savings', 'credit', 'loan', 'other')),
    CHECK (confidence IN ('confirmed', 'inferred', 'review'))
);

CREATE TABLE IF NOT EXISTS statement_coverage (
    account_label VARCHAR NOT NULL,
    month DATE NOT NULL,
    coverage VARCHAR NOT NULL,
    reconciliation VARCHAR NOT NULL,
    notes VARCHAR,
    PRIMARY KEY (account_label, month),
    CHECK (coverage IN ('complete', 'partial', 'missing', 'overlap')),
    CHECK (reconciliation IN
        ('reconciled', 'unreconciled', 'balance-unverified'))
);

CREATE TABLE IF NOT EXISTS statement_reconciliation (
    account_label VARCHAR NOT NULL,
    statement_start DATE NOT NULL,
    statement_end DATE NOT NULL,
    opening_balance DECIMAL(18,2),
    closing_balance DECIMAL(18,2),
    source_activity_total DECIMAL(18,2),
    ledger_activity_total DECIMAL(18,2),
    difference DECIMAL(18,2),
    status VARCHAR NOT NULL,
    source_file VARCHAR NOT NULL,
    CHECK (status IN ('reconciled', 'unreconciled', 'balance-unverified'))
);
```

## Import rules

Import each source into a temporary table first. Then use an explicit `INSERT`
query to normalize the rows.

```sql
CREATE OR REPLACE TEMP TABLE source_rows AS
SELECT *
FROM read_csv('statement.csv', header = true, all_varchar = true);
```

Use `all_varchar = true` for raw CSV values. Cast dates and amounts in the
normalization query. This rule stops automatic type detection from changing a
leading zero, date interpretation, or decimal value.

Do not build SQL with an untrusted filename. Pass the filename through the
DuckDB client API or quote it with a trusted local wrapper.

## Canonical views

```sql
CREATE OR REPLACE VIEW monthly_finance AS
SELECT
    date_trunc('month', posted_date)::DATE AS month,
    currency,
    sum(income_amount) AS income,
    sum(expense_amount) AS spending_before_refunds,
    sum(refund_amount) AS refunds,
    sum(expense_amount - refund_amount) AS net_spending,
    sum(income_amount - expense_amount + refund_amount) AS net_cash_flow,
    sum(transfer_amount) AS transfers
FROM transactions
GROUP BY 1, 2;

CREATE OR REPLACE VIEW quarterly_finance AS
SELECT
    year(month) AS year,
    quarter(month) AS quarter,
    currency,
    sum(income) AS income,
    sum(net_spending) AS net_spending,
    sum(net_cash_flow) AS net_cash_flow,
    sum(transfers) AS transfers
FROM monthly_finance
GROUP BY 1, 2, 3;

CREATE OR REPLACE VIEW yearly_finance AS
SELECT
    year(month) AS year,
    currency,
    sum(income) AS income,
    sum(net_spending) AS net_spending,
    sum(net_cash_flow) AS net_cash_flow,
    sum(transfers) AS transfers
FROM monthly_finance
GROUP BY 1, 2;
```

Keep each currency separate. Do not sum different currencies without an
approved exchange-rate source and an explicit conversion date.

## Duplicate review

This query finds repeated provider IDs:

```sql
SELECT transaction_id, count(*) AS row_count
FROM transactions
GROUP BY transaction_id
HAVING count(*) > 1;
```

This query finds possible duplicates when a provider ID is absent or unstable:

```sql
SELECT
    account_label,
    posted_date,
    raw_amount,
    currency,
    description,
    count(*) AS row_count
FROM transactions
GROUP BY 1, 2, 3, 4, 5
HAVING count(*) > 1;
```

Do not delete the second group automatically. Two valid purchases can have the
same visible fields.

## Verification queries

Quarter totals MUST equal their monthly totals because `quarterly_finance` reads
from `monthly_finance`. Check the independent transaction rollup too:

```sql
WITH direct AS (
    SELECT
        year(posted_date) AS year,
        quarter(posted_date) AS quarter,
        currency,
        sum(expense_amount - refund_amount) AS net_spending
    FROM transactions
    GROUP BY 1, 2, 3
)
SELECT d.*, q.net_spending AS monthly_rollup
FROM direct AS d
JOIN quarterly_finance AS q USING (year, quarter, currency)
WHERE d.net_spending <> q.net_spending;
```

An empty result means that the two rollups agree.

## Export

Render Markdown from query results. Do not make an exported CSV the canonical
ledger. If you export private transaction data, protect it like the database.
