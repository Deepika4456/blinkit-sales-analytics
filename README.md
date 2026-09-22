# Blinkit Sales & Operations Analytics

An end-to-end data analytics project on a simulated Blinkit (quick-commerce) dataset —
from raw data cleaning through SQL-driven business analysis to a 5-page interactive
Power BI dashboard.

## 🔍 Project Overview

This project analyzes 8 relational tables covering customers, orders, products,
delivery performance, marketing campaigns, customer feedback, and inventory, to answer
real business questions across Sales, Delivery Operations, Customer Behavior, and
Marketing ROI.

**Tech stack:** Python (Pandas) · MySQL · Power BI

## 📁 Repository Structure

```
├── Blinkit_Data_Cleaning.ipynb      # Data cleaning notebook (Python/Pandas)
├── clean_data.py                    # Standalone cleaning script
├── blinkit_query_history.sql        # Full SQL query history (as actually run)
├── blinkit_queries_with_results.md  # All 25 queries paired with their actual output
├── blinkit_insights_readme.md       # Compiled findings and data-quality notes
├── Blinkit_Dashboard.pbix           # Power BI dashboard (5 pages)
└── clean/                           # Cleaned CSVs, ready for SQL loading
```

## 🧹 Data Cleaning

Started from 9 raw CSV files. Key cleaning steps:
- Dropped `inventoryNew.csv` — a duplicated, messier monthly rollup of `inventory.csv`
- Converted all date/timestamp columns from text to proper datetime types
- Filled nulls in `reasons_if_delayed` with `"Not Delayed"` (blanks meant on-time
  deliveries, not missing data — dropping them would have deleted 38% of the delivery
  table and specifically the *good* deliveries)
- Added a derived `line_total` column to `order_items` (revenue wasn't a stored field)
- Fixed a `dayfirst` date-parsing bug in `inventory.csv` that would have silently
  corrupted dates where the day was ≤ 12

Full details and code in `Blinkit_Data_Cleaning.ipynb`.

## 🗄️ SQL Analysis

25 business questions answered across 5 sections in MySQL — sales & revenue, delivery
operations, customer analytics, marketing ROI, and inventory. See
`blinkit_queries_with_results.md` for every query paired with its actual output.

### Key headline numbers
| Metric | Value |
|---|---|
| Total Revenue | ₹1.10 Cr |
| Total Orders | 5,000 |
| Avg Order Value | ₹2,201.86 |
| On-Time Delivery Rate | 69.4% |
| Repeat Customer Rate | ~69% |
| Marketing ROAS (corrected) | 1.97x |

### 🚩 Data quality findings (verified through query-based checks, not assumed)
This project treats data validation as part of the analysis, not a preliminary step —
five real inconsistencies were caught and corrected before drawing conclusions:

1. **`store_id` and `delivery_partner_id`** are unique per row (not real, reusable
   IDs) — confirmed via `COUNT(DISTINCT ...)` matching row count exactly. Excluded
   from store/partner-level analysis.
2. **`margin_percentage`** is fixed per category (e.g. all Instant & Frozen Food = 40%),
   not calculated per-product from cost data.
3. **`customer_segment`** (Regular/Premium/New/Inactive) shows no measurable difference
   in order count or spend across segments — behaves like a static/random label.
4. **Marketing `roas` column doesn't match its own revenue/spend** — e.g. one campaign's
   stored ROAS was 1.75 while the actual calculated value was 9.51x. Every ROAS figure
   in this project was recalculated directly as `revenue_generated / spend`.
5. **`damaged_stock` sometimes exceeds `stock_received`** (up to 109.83% "damage"),
   which is logically impossible — the two fields aren't tracking a real batch
   relationship.

## 📊 Dashboard

5-page Power BI dashboard:
- **Overview** — headline KPIs, monthly revenue trend, revenue by category
- **Sales** — top products, payment method mix, product margin table
- **Delivery** — on-time rate, area-level performance (filtered for statistical
  reliability), distance-band analysis
- **Customer** — repeat vs. one-time customers, top spenders, feedback sentiment
- **Marketing** — spend/revenue/ROAS KPIs, channel performance, monthly trend

<img width="1381" height="1017" alt="Screenshot 2026-09-22 120410" src="https://github.com/user-attachments/assets/3d980a27-6483-4bb9-af50-7829dd31cf10" />
<img width="1907" height="1032" alt="Screenshot 2026-09-22 120400" src="https://github.com/user-attachments/assets/4e0b128e-1811-4089-95b6-7c8d68e672fa" />
<img width="1230" height="932" alt="Screenshot 2026-09-22 120418" src="https://github.com/user-attachments/assets/0b9bcd0f-7cb6-4165-86cf-25d071b45479" />
<img width="1307" height="998" alt="Screenshot 2026-09-22 120426" src="https://github.com/user-attachments/assets/efefc7fd-2467-4049-a823-eb6a79dcff44" />
<img width="1341" height="1026" alt="Screenshot 2026-09-22 120444" src="https://github.com/user-attachments/assets/44250c26-fb10-401b-adc2-63a3f4500e1a" />





## 💡 What this project demonstrates
- End-to-end pipeline ownership: raw data → cleaning → SQL analysis → BI dashboard
- Critical thinking over blind trust in data — every non-obvious number was verified
  against a second calculation before being used
- Clear communication of both findings *and* limitations, which is what real
  stakeholder-facing analysis requires
