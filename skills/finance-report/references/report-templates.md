# Report templates

Use these structures as the minimum output. Add useful analysis after the
required sections.

## Monthly report

```markdown
---
type: finance-report
period: YYYY-MM
status: complete | partial
reconciliation: reconciled | unreconciled | balance-unverified
---

# Month YYYY finance report

## Coverage

| Account | Source period | Coverage | Reconciliation | Notes |
| --- | --- | --- | --- | --- |

## Summary

| Measure | Amount |
| --- | ---: |
| Income | |
| Spending before refunds | |
| Refunds | |
| Net spending | |
| Net cash flow | |
| Transfers | |
| Fees | |
| Interest paid | |
| Interest earned | |

## Spending by category

| Category | Amount | Share | Change from prior month |
| --- | ---: | ---: | ---: |

## Activity by account

| Account | Income | Net spending | Transfers in | Transfers out |
| --- | ---: | ---: | ---: | ---: |

## Notable changes

- State only evidence-backed changes.

## Review queue

| Item | Amount | Reason | Source reference |
| --- | ---: | --- | --- |

## Method

- State the aggregation date, currency handling, transfer rule, and missing data.
```

Do not show the `Change from prior month` value when the prior month is missing
or partial.

## Yearly report with quarters

```markdown
---
type: finance-report
period: YYYY
status: complete | partial
reconciliation: reconciled | unreconciled | balance-unverified
---

# YYYY finance report

## Coverage

| Account | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Annual summary

| Measure | Amount |
| --- | ---: |
| Income | |
| Net spending | |
| Net cash flow | |
| Transfers | |
| Fees | |
| Interest paid | |
| Interest earned | |

## Quarterly summary

| Quarter | Coverage | Income | Net spending | Net cash flow | Transfers |
| --- | --- | ---: | ---: | ---: | ---: |
| Q1 | | | | | |
| Q2 | | | | | |
| Q3 | | | | | |
| Q4 | | | | | |
| Year | | | | | |

## Q1: January through March

State totals, major categories, changes, and review items.

## Q2: April through June

State totals, major categories, changes, and review items.

## Q3: July through September

State totals, major categories, changes, and review items.

## Q4: October through December

State totals, major categories, changes, and review items.

## Monthly summary

| Month | Coverage | Income | Net spending | Net cash flow | Transfers |
| --- | --- | ---: | ---: | ---: | ---: |

## Annual spending by category

| Category | Amount | Share | Q1 | Q2 | Q3 | Q4 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |

## Annual activity by account

| Account | Income | Net spending | Transfers in | Transfers out | Reconciliation |
| --- | ---: | ---: | ---: | ---: | --- |

## Notable changes

- Compare complete periods only.

## Review queue

| Item | Amount | Reason | Source reference |
| --- | ---: | --- | --- |

## Method

- State the aggregation date, currency handling, transfer rule, and missing data.
```

## Partial-period rules

- Keep all months and quarters in the report.
- Use `missing` instead of zero when no source covers a period.
- Use `partial` when a source covers only part of a period.
- Do not annualize a partial year unless the user asks for a projection.
- Label a projection as a projection. Keep it separate from actual values.
