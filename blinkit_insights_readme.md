# Blinkit Sales & Operations Analytics — Key Insights

## Dataset Overview
- 8 relational tables: customers, orders, order_items, products, delivery_performance,
  customer_feedback, marketing_performance, inventory
- Data spans March 2023 – November 2024 (first and last months are partial)
- `inventoryNew.csv` was excluded (redundant, duplicated monthly rollup of `inventory.csv`)

## Section 1: Sales & Revenue
- **5,000 orders**, **₹1,10,09,308.50 total revenue**, **₹2,201.86 avg order value**
- Top product: **Baby Food** (₹65,212.70, 70 units)
- "Vitamins" appears twice in top 10 — separate SKUs/brands under one name (SKU-level granularity noted)
- Top category: **Dairy & Breakfast** (₹6.39L), followed by Pharmacy (₹5.92L), Fruits & Vegetables (₹5.59L)
  — no single category dominates; diversified revenue base
- Monthly revenue stable at ~₹500K–620K/month (mature business, not scaling fast)
- Payment methods evenly split: Card, Cash, Wallet, UPI each ~25% of revenue — no channel risk
- **Data limitation:** `store_id` is unique per order (5000 distinct values for 5000 orders) —
  not usable for store-level analysis
- **Data limitation:** `margin_percentage` appears fixed per category (e.g. all Instant & Frozen
  Food = 40%), not calculated per-product from real cost data

## Section 2: Delivery / Operations
- **69.4% on-time delivery rate** (3,470 On Time / 1,037 Slightly Delayed / 493 Significantly Delayed)
- Average delay when late: **8.7 minutes** (mild on average)
- **Data limitation:** `reasons_if_delayed` only ever contains "Traffic", and appears on 1,568
  On Time deliveries too — not a reliable root-cause field, excluded from dashboard
- **Data limitation:** `delivery_partner_id` is unique per delivery — not usable for
  partner-level performance analysis
- On-time rate by area varies meaningfully at higher volumes (15+ deliveries): Ghaziabad (32,
  56.25%), Agra (27, 55.56%), Bulandshahr (27, 55.56%) are real underperformers vs. low-volume
  statistical noise (e.g. single-delivery areas showing 0%/100%)
- Nearly all deliveries occur within 5km (quick-commerce/dark-store model); on-time rate flat
  (~69%) regardless of distance — distance is not a delay driver

## Section 3: Customer Analytics
- **69% of customers are repeat buyers** (1,492 repeat / 680 one-time) — strong retention signal
- **Data limitation:** `customer_segment` (Regular/Premium/New/Inactive) shows no meaningful
  difference in order count (~10-11) or avg order value (~₹1,090-1,117) across segments —
  appears to be a static/random label, not behavior-derived
- Top spender: Rayaan Krishna, ₹21,686.80 across 6 orders — top spenders span all segments
  including "Inactive", reinforcing the segment-label finding above
- Customer registrations steady (~110-140/month), March 2024 spike to 178
- Feedback sentiment is internally consistent: Positive avg rating 4.50, Neutral 3.52,
  Negative 2.01 (2,000 total feedback records)
- **Finding:** Delivery delay shows no measurable impact on customer rating (On Time 3.33,
  Slightly Delayed 3.39, Significantly Delayed 3.33) — ratings likely driven by other factors
  or generated independently of delivery data in this dataset
- Feedback categories (Delivery, Customer Service, Product Quality, App Experience) are evenly
  split (~1,213-1,271 mentions each) with near-identical avg ratings (~3.3) — no category
  stands out as a particular pain point

## Section 4: Marketing ROI
- Overall: **₹1.63Cr spend → ₹3.22Cr revenue → 1.97x ROAS**
- CTR 10.09%, conversion rate 10.02% — both far above typical real-world benchmarks (1-3%),
  indicating synthetic/idealized marketing data
- Channel ROAS tightly clustered (1.92-2.05x): Email slightly best, App slightly weakest —
  not a strong differentiator
- Target audience ROAS also tightly clustered (1.94-1.99x) — no standout segment
- **Major data quality finding:** the provided `roas` column does NOT match calculated
  revenue/spend (e.g. "Referral Program" stored roas = 1.75 vs. calculated = 9.51). The column
  is unreliable and was ignored throughout — all ROAS figures in this project are calculated
  directly as `revenue_generated / spend`
- Monthly spend/revenue stable (~₹800-880K spend, ~₹1.58-1.73M revenue), no seasonal spikes

## Section 5: Inventory
- **Data limitation:** several products show damage exceeding stock received (e.g. Detergent:
  324 damaged of 295 received = 109.83%), which is logically impossible — `damaged_stock` and
  `stock_received` appear independently generated rather than reflecting real batch tracking.
  Inventory analysis limited to aggregate trends, not per-product damage-rate claims.

## Overall data quality notes (for methodology/limitations section of README)
- `store_id`, `delivery_partner_id`: unique per row, not usable as grouping dimensions
- `margin_percentage`: fixed per category, not calculated per-product
- `customer_segment`: shows no behavioral differentiation, likely a static/random label
- `reasons_if_delayed`: only one value ("Traffic"), appears on many On Time deliveries too
- `roas` (marketing): does not match calculated revenue/spend — always recalculate
- `damaged_stock` vs `stock_received`: inconsistent, damage can exceed stock received
- March 2023 and November 2024 are partial months at the dataset's boundaries — exclude or
  flag when charting trends
