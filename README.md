# Tesla business analytics using Python, PostgreSQL and Power BI

A Tesla-themed learning project covering customer, order and payment analysis. Python was used for data preparation, PostgreSQL for querying, and Power BI for a three-page interactive report.

The project examines customer distribution, product performance, order statuses, payments and refunds.

## Dataset

The supplied data consists of three CSV files:

| Dataset | Raw records | Records after ID deduplication | Main identifier |
| --- | ---: | ---: | --- |
| Customers | 10,166 | 10,000 | customer_id |
| Orders | 10,166 | 10,000 | order_id |
| Revenue | 9,696 | 9,696 | revenue_id |

The customer and order files each contain 166 exact duplicate rows.

Fields cover customer details, location, membership tier, signup date, product category, quantity, unit price, order status, payment method, payment date, payment status and refund amount.

Order dates span January 2023 to December 2025. Monetary fields are labelled in USD.

The dataset includes eight product categories: Model 3, Model S, Model X, Model Y, Powerwall, Solar Panel Kit, Supercharging Credits and Merchandise.

The original dataset source and its connection to actual Tesla operations have not been confirmed. This project treats the files as practice data rather than verified Tesla business records.

## Tech stack

| Tool | Use in this project |
| --- | --- |
| Python | Cleaned customer, order and payment data using pandas |
| Jupyter Notebook | Documented data inspection and cleaning steps |
| PostgreSQL | Created related tables and performed SQL analysis |
| Power BI Desktop | Built report pages, charts, cards, tables and slicers |
| DAX | Calculated customer and order counts, payment totals, refunds and ratios |

## Data preparation

1. Inspected record counts, data types, missing values and duplicates.
2. Removed duplicate customer, order and revenue IDs, keeping the first record.
3. Standardized email text and replaced standalone `at` with `@`.
4. Retained missing emails and created an `email_missing` flag.
5. Replaced missing membership tiers and order statuses with `Unknown`.
6. Standardized selected location, product category and payment-method labels.
7. Removed currency symbols and separators before converting prices and amounts to numeric values.
8. Parsed mixed date formats.
9. Converted negative quantities to positive values in the original workflow.
10. Filled missing payment amounts using quantity multiplied by unit price.


## SQL analysis

The SQL work covers:

- Table creation with primary and foreign keys.
- Record counts, missing-value checks and data previews.
- Aggregate functions and grouped comparisons.
- Joins across customers, orders and payment records.
- Conditional logic using `CASE`.
- Subqueries and common table expressions.
- Window functions, including `RANK`, `DENSE_RANK` and `ROW_NUMBER`.
- A reusable view combining customer, order and payment details.

The analysis compares customer distribution, membership tiers, product categories, payment methods and recorded payment amounts.

Customer-level comparisons should group by `customer_id` as well as customer name to avoid combining different people with the same name.

## Report pages

### Business overview

The original report page is named **Tesla Sales Analytics**.

It presents customer and order counts, recorded payment totals, refunds and the payment-minus-refund measure. Charts compare countries, product categories, membership tiers, order statuses and payment statuses, alongside a trend by order month.

### Customer analytics

Customer counts by country, region and membership tier, customer-level payment comparisons, a geographic map and a detail table.

Slicers cover country, state or region, product category and membership tier.

### Product performance

The original report page is named **Vehicles Sales Performance**.

It compares product quantities, recorded payment amounts, refunds by payment method and geographic distribution, with a category-level summary table.

The dataset includes non-vehicle products, so quantities across all categories should not be described as vehicle units.

## Findings and interpretation

The supplied data and a replay of the notebook's cleaning logic support these observations:

- Model X contributes the largest sum of recorded and imputed payment amounts among product categories.
- `Paid` is the largest payment-status group, with 7,670 records, followed by 1,359 `Refunded` and 667 `Pending` records.
- After removing duplicate order IDs, `Delivered` is the largest order-status group, with 4,103 orders.
- Some orders have multiple payment records, so payment counts and order counts represent different things.


### Reconciliation note

Replaying the notebook's cleaning logic produces approximately $362.07 million in payment amounts and $53.28 million in refunds.

The supplied report screenshots show approximately $344.80 million in payment amounts and $53.28 million in refunds.

The payment difference has not been reconciled. The notebook results and report screenshots should therefore not be treated as matching outputs.

## Technical notes

### Data structure and aggregation

The three tables contain different levels of detail:

| Table | Level of detail | Relationship key |
| --- | --- | --- |
| Customers | One record per customer after deduplication | customer_id |
| Orders | One record per order after deduplication | customer_id |
| Revenue | One record per payment ID | order_id |

Customers connect to orders through `customer_id`. Orders connect to payment records through `order_id`.

All order customer references and payment order references match the supplied tables after ID deduplication.

The revenue file contains 9,696 payment records referencing 9,539 distinct orders. Joining payments to orders can repeat order-level quantities. Payment amounts should be aggregated to order level before combining them with order-level totals where necessary.

### Metric definitions

| Metric | Documented calculation | Interpretation |
| --- | --- | --- |
| Total customers | Distinct customer IDs | Registered customers in the current filter context |
| Total orders | Distinct order IDs | Orders in the current filter context |
| Total payment amount | Sum of amount_paid_usd | Includes all statuses and imputed amounts |
| Total refunds | Sum of refund_amount_usd | Recorded refund amounts |
| Net revenue | Payment amount minus refunds | Payment-minus-refund measure, not profit |
| Refund ratio | Refund amount divided by payment amount | Amount-based ratio, not the percentage of orders refunded |
| Total quantity | Sum of cleaned quantity | Includes non-vehicle categories and converted negative quantities |

The original average order value formula divides net revenue by total revenue. This produces a ratio rather than an order value and requires correction.

An amount-per-order measure needs an agreed payment definition and a matching set of eligible orders.

The documented `Completed` payment-status filter also needs review because the supplied payment labels are `Paid`, `Refunded` and `Pending`.

### Chart choices and interpretation

Bar and column charts compare countries, categories and statuses. The customer table provides detail behind the summary cards, while maps show the geographic distribution recorded in the dataset.



## Repository layout

```text
tesla-business-analytics/
├── data/
│   ├── raw/
│   │   ├── tesla_customers.csv
│   │   ├── tesla_orders.csv
│   │   └── tesla_revenue.csv
│   └── processed/
│       ├── customers_cleaned.csv
│       ├── orders_cleaned.csv
│       └── revenue_cleaned.csv
├── dax/
│   └── dax.docx
├── notebooks/
│   └── tesladataclean.ipynb
├── reports/
│   └── tesla_report.pbix
├── screenshots/
│   ├── customer_analytics_dashboard.png
│   ├── tesla_sales_analytics.png
│   └── vehicle_sales_performance.png
├── sql/
│   └── tesla_business_analytics.sql
├── LICENSE
└── README.md
```

