# Normalized ledger

Use one row for each source transaction. Keep all raw evidence needed to audit
the normalized values.

## Required fields

| Field | Meaning |
| --- | --- |
| `transaction_id` | Provider ID or deterministic local ID |
| `account_label` | Stable redacted account label |
| `account_type` | `checking`, `savings`, `credit`, `loan`, or `other` |
| `institution` | Institution name |
| `transaction_date` | Date on which the transaction occurred |
| `posted_date` | Date used for monthly aggregation |
| `description` | Normalized private description |
| `merchant` | Normalized merchant when known |
| `raw_category` | Category from the source |
| `category` | Normalized reporting category |
| `kind` | `expense`, `income`, `transfer`, `refund`, `fee`, `interest`, `adjustment`, or `unknown` |
| `expense_amount` | Positive decimal expense amount, otherwise zero |
| `income_amount` | Positive decimal income amount, otherwise zero |
| `transfer_amount` | Positive decimal transfer magnitude, otherwise zero |
| `refund_amount` | Positive decimal refund amount, otherwise zero |
| `raw_amount` | Exact amount from the source |
| `currency` | ISO 4217 code when known |
| `source_file` | Source filename or stable source ID |
| `source_locator` | CSV row, OFX transaction ID, or PDF page and table row |
| `statement_start` | Statement start date |
| `statement_end` | Statement end date |
| `confidence` | `confirmed`, `inferred`, or `review` |
| `notes` | Short explanation for an exception |

Use a decimal value with two source currency digits unless the source has more
precision. Store dates in `YYYY-MM-DD` format.

## Sign normalization

Report amounts are positive magnitudes:

- A purchase sets `expense_amount`.
- A bank withdrawal that pays for goods or services sets `expense_amount`.
- A deposit from an external payer sets `income_amount`.
- A refund sets `refund_amount`. It reduces spending for its category. Keep
  `kind=refund`.
- A fee sets `expense_amount` and uses the `Fees` category.
- Interest paid by a bank sets `income_amount`.
- Interest charged by a lender sets `expense_amount`.
- A transfer sets only `transfer_amount`.

Preserve `raw_amount`. Do not infer meaning from its sign alone.

When you aggregate net spending, calculate:

`expenses + fees + charged interest - refunds`

When you aggregate net cash flow, calculate:

`income - net spending`

Transfers do not enter either value.

## Apple Card CSV adapter

Recognize this header set:

`Transaction Date,Clearing Date,Description,Merchant,Category,Type,Amount (USD),Purchased By`

Use these rules:

| Source value | Normalized value |
| --- | --- |
| `Clearing Date` | `posted_date` |
| `Transaction Date` | `transaction_date` |
| `Purchase` | `kind=expense`; positive `expense_amount` |
| `Payment` | `kind=transfer`; absolute `transfer_amount` |
| `Credit` or `Return` | `kind=refund`; absolute refund amount |
| `Amount (USD)` | `raw_amount`; currency is `USD` |

Preserve `Purchased By` in the private ledger only when ownership analysis is in
scope. Do not expose the value in a report unless the user asks for it.

Confirm new or unknown `Type` values before classification.

## Generic bank CSV adapter

Map semantic fields, not fixed column positions. Common variants include:

| Meaning | Common headers |
| --- | --- |
| Posted date | `Date`, `Posted Date`, `Posting Date`, `Clearing Date` |
| Description | `Description`, `Memo`, `Name`, `Payee` |
| Amount | `Amount`, `Transaction Amount` |
| Split amount | `Debit` and `Credit`, `Withdrawal` and `Deposit` |
| Type | `Type`, `Transaction Type` |
| ID | `Transaction ID`, `Reference`, `FITID` |

Determine whether a positive source amount means an inflow or an outflow. Confirm
the rule against the statement summary.

## Deduplication

Use this priority:

1. Provider account identifier plus provider transaction ID.
2. Account label plus OFX `FITID`.
3. Account label, posted date, exact raw amount, currency, normalized
   description, and a stable occurrence number.

Treat possible duplicates as review items when evidence is not conclusive.

## Transfer matching

Match two transfer candidates when all conditions hold:

- amounts and currencies match;
- their signs or account effects oppose each other;
- dates fall within the allowed posting window;
- descriptions or account context support the match.

Use a three-business-day window by default. Expand the window only when statement
evidence supports it.

One source can contain only one side of a transfer. Mark that row as an
`unmatched transfer`. Do not convert it to income or spending.

## Reconciliation record

Keep one record for each account and statement:

| Field | Meaning |
| --- | --- |
| `opening_balance` | Source opening balance |
| `closing_balance` | Source closing balance |
| `source_activity_total` | Activity total printed by the source |
| `ledger_activity_total` | Total calculated from normalized rows |
| `difference` | Source total minus ledger total |
| `status` | `reconciled`, `unreconciled`, or `balance-unverified` |

Do not add a synthetic row only to remove a difference.
