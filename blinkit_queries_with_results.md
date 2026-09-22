# Blinkit Analytics — SQL Queries & Results Log

Each query below was run individually in MySQL Workbench against the `blinkitdb`
database, with the actual output recorded underneath.

---

## SECTION 1: SALES & REVENUE

### 1.1 Total revenue, total orders, average order value
```sql
SELECT
    COUNT(DISTINCT order_id)   AS total_orders,
    ROUND(SUM(order_total), 2) AS total_revenue,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM orders;
```
**Result:**
| total_orders | total_revenue | avg_order_value |
|---|---|---|
| 5000 | 11009308.50 | 2201.86 |

---

### 1.2 Top 10 products by revenue
```sql
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)              AS units_sold,
    ROUND(SUM(oi.line_total), 2)  AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;
```
**Result:**
| product_name | category | units_sold | total_revenue |
|---|---|---|---|
| Baby Food | Baby Care | 70 | 65212.70 |
| Mangoes | Fruits & Vegetables | 61 | 56464.65 |
| Bread | Dairy & Breakfast | 58 | 55182.94 |
| Vitamins | Pharmacy | 55 | 51830.35 |
| Vitamins | Pharmacy | 52 | 51790.96 |
| Toilet Cleaner | Household Care | 49 | 48733.44 |
| Dish Soap | Household Care | 48 | 46509.12 |
| Eggs | Dairy & Breakfast | 46 | 45534.48 |
| Onions | Fruits & Vegetables | 48 | 44868.00 |
| Toothpaste | Personal Care | 50 | 43899.00 |

*Note: "Vitamins" appears twice — two separate SKUs/product_ids share the same name.*

---

### 1.3 Revenue by category
```sql
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS category_revenue,
    SUM(oi.quantity)             AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;
```
**Result:**
| category | category_revenue | units_sold |
|---|---|---|
| Dairy & Breakfast | 639222.19 | 1114 |
| Pharmacy | 592368.57 | 973 |
| Fruits & Vegetables | 559053.08 | 966 |
| Pet Care | 539888.75 | 1003 |
| Household Care | 444244.25 | 1078 |
| Personal Care | 394894.61 | 887 |
| Snacks & Munchies | 394648.71 | 963 |
| Cold Drinks & Juices | 392717.62 | 758 |
| Grocery & Staples | 359937.82 | 895 |
| Baby Care | 348227.18 | 655 |
| Instant & Frozen Food | 307212.65 | 742 |

---

### 1.4 Monthly revenue trend
```sql
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT order_id)         AS orders,
    ROUND(SUM(order_total), 2)       AS revenue
FROM orders
GROUP BY month
ORDER BY month;
```
**Result:**
| month | orders | revenue |
|---|---|---|
| 2023-03 | 120 | 272878.96 |
| 2023-04 | 238 | 554344.77 |
| 2023-05 | 276 | 608213.54 |
| 2023-06 | 232 | 505227.66 |
| 2023-07 | 244 | 567639.91 |
| 2023-08 | 285 | 623472.35 |
| 2023-09 | 262 | 571117.81 |
| 2023-10 | 254 | 578369.83 |
| 2023-11 | 265 | 567783.74 |
| 2023-12 | 268 | 615709.03 |
| 2024-01 | 270 | 560423.56 |
| 2024-02 | 252 | 545090.11 |
| 2024-03 | 251 | 543181.85 |
| 2024-04 | 241 | 538754.75 |
| 2024-05 | 263 | 574163.61 |
| 2024-06 | 248 | 539074.85 |
| 2024-07 | 256 | 573111.98 |
| 2024-08 | 251 | 546194.57 |
| 2024-09 | 247 | 518695.03 |
| 2024-10 | 247 | 537702.94 |
| 2024-11 | 30 | 68157.65 |

*Note: March 2023 and November 2024 are partial months at the dataset's boundaries.*

---

### 1.5 Revenue by payment method
```sql
SELECT
    payment_method,
    COUNT(*)                    AS orders,
    ROUND(SUM(order_total), 2)  AS revenue
FROM orders
GROUP BY payment_method
ORDER BY revenue DESC;
```
**Result:**
| payment_method | orders | revenue |
|---|---|---|
| Card | 1285 | 2865557.53 |
| Cash | 1257 | 2770463.99 |
| Wallet | 1244 | 2715004.27 |
| UPI | 1214 | 2658282.71 |

---

### 1.6 Revenue by store
```sql
SELECT
    store_id,
    COUNT(DISTINCT order_id)   AS orders,
    ROUND(SUM(order_total), 2) AS revenue
FROM orders
GROUP BY store_id
ORDER BY revenue DESC;
```
**Result:** Every `store_id` returned exactly 1 order.
```sql
SELECT COUNT(DISTINCT store_id) AS unique_stores, COUNT(*) AS total_orders FROM orders;
```
**Result:** `unique_stores = 5000`, `total_orders = 5000`
**Finding:** `store_id` is unique per order — not usable for store-level analysis. Excluded from dashboard.

---

### 1.7 Highest margin products
```sql
SELECT
    product_name, category, price, mrp, margin_percentage
FROM products
ORDER BY margin_percentage DESC
LIMIT 10;
```
**Result:** All 10 rows were **Instant & Frozen Food** products, every one at exactly **40%** margin.
```sql
SELECT category, COUNT(DISTINCT margin_percentage) AS distinct_margins, MIN(margin_percentage), MAX(margin_percentage)
FROM products GROUP BY category;
```
**Finding:** `margin_percentage` is fixed per category, not calculated per-product.

---

## SECTION 2: DELIVERY / OPERATIONS

### 2.1 Overall on-time delivery rate
```sql
SELECT
    delivery_status,
    COUNT(*) AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM delivery_performance
GROUP BY delivery_status;
```
**Result:**
| delivery_status | orders | pct_of_total |
|---|---|---|
| On Time | 3470 | 69.40 |
| Slightly Delayed | 1037 | 20.74 |
| Significantly Delayed | 493 | 9.86 |

---

### 2.2 Average delivery delay (minutes)
```sql
SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, promised_time, actual_time)), 1) AS avg_delay_minutes
FROM delivery_performance
WHERE actual_time > promised_time;
```
**Result:** `avg_delay_minutes = 8.7`

---

### 2.3 Top reasons for delay
```sql
SELECT reasons_if_delayed, COUNT(*) AS count
FROM delivery_performance
GROUP BY reasons_if_delayed
ORDER BY count DESC;
```
**Result:** `Traffic: 3098`, `Not Delayed: 1902`

Cross-tab check:
```sql
SELECT delivery_status, reasons_if_delayed, COUNT(*) AS count
FROM delivery_performance
GROUP BY delivery_status, reasons_if_delayed
ORDER BY delivery_status;
```
**Result:**
| delivery_status | reasons_if_delayed | count |
|---|---|---|
| On Time | Not Delayed | 1902 |
| On Time | Traffic | 1568 |
| Significantly Delayed | Traffic | 493 |
| Slightly Delayed | Traffic | 1037 |

**Finding:** "Traffic" appears on 1,568 On Time deliveries too — not a reliable root-cause field.

---

### 2.4 Delivery performance by delivery partner
```sql
SELECT
    delivery_partner_id,
    COUNT(*) AS total_deliveries, ...
FROM delivery_performance
GROUP BY delivery_partner_id
ORDER BY on_time_pct ASC;
```
**Result:** Every `delivery_partner_id` returned exactly 1 delivery (confirmed via `COUNT(DISTINCT delivery_partner_id) = 5000` matching `COUNT(*) = 5000`).
**Finding:** `delivery_partner_id` unique per row — not usable for partner-level analysis.

---

### 2.5 Delivery performance by area
```sql
SELECT
    c.area,
    COUNT(*) AS total_deliveries,
    ROUND(SUM(CASE WHEN dp.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivery_performance dp
JOIN orders o    ON o.order_id = dp.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.area
ORDER BY on_time_pct ASC;
```
**Result (sample, filtered to 15+ deliveries for reliability):**
| area | total_deliveries | on_time_pct |
|---|---|---|
| Ghaziabad | 32 | 56.25 |
| Agra | 27 | 55.56 |
| Bulandshahr | 27 | 55.56 |
| Rajahmundry | 18 | 38.89 |
| Sonipat | 22 | 45.45 |

*(Full result set spans ~280 areas; low-volume areas with n<15 show unreliable 0%/100% extremes.)*

---

### 2.6 Distance vs delay
```sql
SELECT
    CASE WHEN distance_km < 2 THEN '0-2 km' WHEN distance_km < 5 THEN '2-5 km'
         WHEN distance_km < 8 THEN '5-8 km' ELSE '8+ km' END AS distance_band,
    COUNT(*) AS deliveries,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivery_performance
GROUP BY distance_band
ORDER BY distance_band;
```
**Result:**
| distance_band | deliveries | on_time_pct |
|---|---|---|
| 0-2 km | 1731 | 68.86 |
| 2-5 km | 3264 | 69.70 |
| 5-8 km | 5 | 60.00 |

**Finding:** Distance is not a meaningful driver of delay; on-time rate flat (~69%) across bands.

---

## SECTION 3: CUSTOMER ANALYTICS

### 3.1 Customers by segment
```sql
SELECT customer_segment, COUNT(*) AS customers,
    ROUND(AVG(total_orders), 1) AS avg_orders_per_customer,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value
FROM customers GROUP BY customer_segment ORDER BY customers DESC;
```
**Result:**
| customer_segment | customers | avg_orders_per_customer | avg_order_value |
|---|---|---|---|
| Regular | 639 | 10.3 | 1089.47 |
| Premium | 633 | 10.2 | 1101.47 |
| New | 628 | 10.9 | 1116.64 |
| Inactive | 600 | 10.6 | 1102.15 |

**Finding:** No meaningful behavioral difference across segments — likely a static/random label.

---

### 3.2 Top 10 customers by lifetime spend
```sql
SELECT c.customer_id, c.customer_name, c.customer_segment,
    COUNT(o.order_id) AS orders_placed, ROUND(SUM(o.order_total), 2) AS lifetime_spend
FROM customers c JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY lifetime_spend DESC LIMIT 10;
```
**Result:**
| customer_id | customer_name | customer_segment | orders_placed | lifetime_spend |
|---|---|---|---|---|
| 22210238 | Rayaan Krishna | New | 6 | 21686.80 |
| 77869660 | Nidhi Sha | Premium | 9 | 19052.94 |
| 8791577 | Warda Kohli | Regular | 8 | 19028.36 |
| 26285589 | Bakhshi De | New | 7 | 18912.97 |
| 91196901 | Atharv Kurian | Premium | 5 | 18856.11 |
| 17805991 | Jhalak Rai | New | 8 | 18409.90 |
| 17597449 | Umang Dhingra | Inactive | 5 | 17857.34 |
| 11478478 | Vedika Dugal | Inactive | 6 | 17719.29 |
| 25128143 | Odika Kannan | Premium | 7 | 17638.83 |
| 67092149 | Daksh Atwal | Premium | 5 | 17572.43 |

---

### 3.3 Repeat vs one-time customers
```sql
SELECT CASE WHEN order_count = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type, COUNT(*) AS customers
FROM (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id) t
GROUP BY customer_type;
```
**Result:** `Repeat: 1492`, `One-time: 680`

---

### 3.4 Customer registrations over time
```sql
SELECT DATE_FORMAT(registration_date, '%Y-%m') AS month, COUNT(*) AS new_customers
FROM customers GROUP BY month ORDER BY month;
```
**Result (sample):** Steady ~110-140/month, March 2024 spiked to 178, November 2024 dropped to 17 (partial month).

---

### 3.5 Feedback sentiment breakdown
```sql
SELECT sentiment, COUNT(*) AS feedback_count, ROUND(AVG(rating), 2) AS avg_rating
FROM customer_feedback GROUP BY sentiment ORDER BY feedback_count DESC;
```
**Result:**
| sentiment | feedback_count | avg_rating |
|---|---|---|
| Neutral | 1738 | 3.52 |
| Negative | 1642 | 2.01 |
| Positive | 1620 | 4.50 |

---

### 3.6 Delivery delay vs feedback rating
```sql
SELECT dp.delivery_status, ROUND(AVG(cf.rating), 2) AS avg_rating, COUNT(*) AS feedback_count
FROM customer_feedback cf JOIN delivery_performance dp ON dp.order_id = cf.order_id
GROUP BY dp.delivery_status;
```
**Result:**
| delivery_status | avg_rating | feedback_count |
|---|---|---|
| On Time | 3.33 | 3470 |
| Slightly Delayed | 3.39 | 1037 |
| Significantly Delayed | 3.33 | 493 |

**Finding:** No measurable impact of delivery delay on customer rating.

---

### 3.7 Feedback by category
```sql
SELECT feedback_category, COUNT(*) AS mentions, ROUND(AVG(rating), 2) AS avg_rating
FROM customer_feedback GROUP BY feedback_category ORDER BY mentions DESC;
```
**Result:**
| feedback_category | mentions | avg_rating |
|---|---|---|
| Delivery | 1271 | 3.33 |
| Customer Service | 1266 | 3.37 |
| Product Quality | 1250 | 3.32 |
| App Experience | 1213 | 3.36 |

---

## SECTION 4: MARKETING ROI

### 4.1 Overall marketing performance summary
```sql
SELECT ROUND(SUM(spend), 2) AS total_spend, ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(SUM(revenue_generated) / SUM(spend), 2) AS overall_roas,
    SUM(impressions) AS total_impressions, SUM(clicks) AS total_clicks, SUM(conversions) AS total_conversions,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS ctr_pct,
    ROUND(SUM(conversions) * 100.0 / SUM(clicks), 2) AS conversion_rate_pct
FROM marketing_performance;
```
**Result:**
| total_spend | total_revenue | overall_roas | total_impressions | total_clicks | total_conversions | ctr_pct | conversion_rate_pct |
|---|---|---|---|---|---|---|---|
| 16319838.24 | 32193407.37 | 1.97 | 29487610 | 2974145 | 298038 | 10.09 | 10.02 |

---

### 4.2 ROAS by channel
```sql
SELECT channel, ROUND(SUM(spend), 2) AS total_spend, ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(SUM(revenue_generated) / SUM(spend), 2) AS roas
FROM marketing_performance GROUP BY channel ORDER BY roas DESC;
```
**Result:**
| channel | total_spend | total_revenue | roas |
|---|---|---|---|
| Email | 3997488.04 | 8189331.58 | 2.05 |
| SMS | 3998607.54 | 7938649.32 | 1.99 |
| Social Media | 4110363.91 | 7990415.98 | 1.94 |
| App | 4213378.75 | 8075010.49 | 1.92 |

---

### 4.3 Best performing campaigns by stored ROAS (before correction)
```sql
SELECT campaign_name, channel, target_audience, ROUND(spend, 2) AS spend,
    ROUND(revenue_generated, 2) AS revenue, roas
FROM marketing_performance ORDER BY roas DESC LIMIT 10;
```
**Result (sample):** Top rows all showed stored `roas` of ~4.0, e.g. "Weekend Special" (Email): spend 4340.54, revenue 5844.89, stored roas 3.99.

**Verification query — stored vs calculated ROAS:**
```sql
SELECT campaign_name, ROUND(spend, 2) AS spend, ROUND(revenue_generated, 2) AS revenue,
    roas AS stored_roas, ROUND(revenue_generated / spend, 2) AS calculated_roas
FROM marketing_performance
ORDER BY ABS(roas - (revenue_generated / spend)) DESC LIMIT 10;
```
**Result:**
| campaign_name | spend | revenue | stored_roas | calculated_roas |
|---|---|---|---|---|
| Referral Program | 1027.21 | 9771.28 | 1.75 | 9.51 |
| New User Discount | 1025.98 | 9484.10 | 1.93 | 9.24 |
| App Push Notification | 1010.36 | 9099.22 | 1.78 | 9.01 |
| App Push Notification | 1118.46 | 9686.32 | 1.67 | 8.66 |
| Category Promotion | 1086.76 | 9649.42 | 1.92 | 8.88 |

**Major finding:** The stored `roas` column does NOT match calculated revenue/spend — used as an unreliable field. All ROAS figures in this project were recalculated directly as `revenue_generated / spend`.

---

### 4.4 Performance by target audience
```sql
SELECT target_audience, ROUND(SUM(spend), 2) AS total_spend, ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(SUM(revenue_generated) / SUM(spend), 2) AS calculated_roas
FROM marketing_performance GROUP BY target_audience ORDER BY calculated_roas DESC;
```
**Result:**
| target_audience | total_spend | total_revenue | calculated_roas |
|---|---|---|---|
| Inactive | 4077275.86 | 8105791.01 | 1.99 |
| New Users | 4082313.37 | 8142498.88 | 1.99 |
| Premium | 4049941.41 | 7966479.19 | 1.97 |
| All | 4110307.60 | 7978638.29 | 1.94 |

---

### 4.5 Monthly marketing spend vs revenue trend
```sql
SELECT DATE_FORMAT(date, '%Y-%m') AS month, ROUND(SUM(spend), 2) AS spend, ROUND(SUM(revenue_generated), 2) AS revenue
FROM marketing_performance GROUP BY month ORDER BY month;
```
**Result (sample):** Stable ~₹800-880K spend, ~₹1.58-1.73M revenue per month; March 2023 and Nov 2024 are partial-boundary months.

---

## SECTION 5: INVENTORY (bonus)

### 5.1 Products with highest damage rate
```sql
SELECT p.product_name, SUM(i.stock_received) AS total_received, SUM(i.damaged_stock) AS total_damaged,
    ROUND(SUM(i.damaged_stock) * 100.0 / SUM(i.stock_received), 2) AS damage_pct
FROM inventory i JOIN products p ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name
HAVING total_received > 0 ORDER BY damage_pct DESC LIMIT 10;
```
**Result:**
| product_name | total_received | total_damaged | damage_pct |
|---|---|---|---|
| Detergent | 295 | 324 | 109.83 |
| Toilet Cleaner | 292 | 300 | 102.74 |
| Dish Soap | 330 | 338 | 102.42 |
| Detergent | 314 | 300 | 95.54 |
| Toilet Cleaner | 318 | 298 | 93.71 |

**Finding:** Damage percentages exceeding 100% are logically impossible — `damaged_stock` and `stock_received` appear independently generated, not a true batch-tracking relationship.
