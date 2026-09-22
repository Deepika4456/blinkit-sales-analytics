-- ============================================================
-- BLINKIT ANALYTICS: BUSINESS QUESTION QUERIES
-- ============================================================

-- ============================================================
-- SECTION 1: SALES & REVENUE
-- ============================================================

-- 1.1 Total revenue, total orders, average order value
SELECT
    COUNT(DISTINCT order_id)   AS total_orders,
    ROUND(SUM(order_total), 2) AS total_revenue,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM orders;

-- 1.2 Top 10 products by revenue
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

-- 1.3 Revenue by category
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS category_revenue,
    SUM(oi.quantity)             AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 1.4 Monthly revenue trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT order_id)         AS orders,
    ROUND(SUM(order_total), 2)       AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- 1.5 Revenue by payment method
SELECT
    payment_method,
    COUNT(*)                    AS orders,
    ROUND(SUM(order_total), 2)  AS revenue
FROM orders
GROUP BY payment_method
ORDER BY revenue DESC;

-- 1.6 Revenue by store
SELECT
    store_id,
    COUNT(DISTINCT order_id)   AS orders,
    ROUND(SUM(order_total), 2) AS revenue
FROM orders
GROUP BY store_id
ORDER BY revenue DESC;

-- 1.7 Highest margin products (pricing/profitability angle)
SELECT
    product_name,
    category,
    price,
    mrp,
    margin_percentage
FROM products
ORDER BY margin_percentage DESC
LIMIT 10;


-- ============================================================
-- SECTION 2: DELIVERY / OPERATIONS
-- ============================================================

-- 2.1 Overall on-time delivery rate
SELECT
    delivery_status,
    COUNT(*)                                              AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)     AS pct_of_total
FROM delivery_performance
GROUP BY delivery_status;

-- 2.2 Average delivery delay (promised vs actual), in minutes
SELECT
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, promised_time, actual_time)), 1) AS avg_delay_minutes
FROM delivery_performance
WHERE actual_time > promised_time;

-- 2.3 Top reasons for delay
SELECT
    reasons_if_delayed,
    COUNT(*) AS occurrences
FROM delivery_performance
WHERE reasons_if_delayed <> 'Not Delayed'
GROUP BY reasons_if_delayed
ORDER BY occurrences DESC;

-- 2.4 Delivery performance by delivery partner
SELECT
    delivery_partner_id,
    COUNT(*)                                                          AS total_deliveries,
    SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END)      AS on_time_deliveries,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                                      AS on_time_pct,
    ROUND(AVG(distance_km), 2)                                        AS avg_distance_km
FROM delivery_performance
GROUP BY delivery_partner_id
ORDER BY on_time_pct ASC;

-- 2.5 Delivery performance by area (join through orders -> customers)
SELECT
    c.area,
    COUNT(*)                                                     AS total_deliveries,
    ROUND(SUM(CASE WHEN dp.delivery_status = 'On Time' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                                 AS on_time_pct
FROM delivery_performance dp
JOIN orders o    ON o.order_id = dp.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.area
ORDER BY on_time_pct ASC;

-- 2.6 Distance vs delay relationship (does farther = more delay?)
SELECT
    CASE
        WHEN distance_km < 2 THEN '0-2 km'
        WHEN distance_km < 5 THEN '2-5 km'
        WHEN distance_km < 8 THEN '5-8 km'
        ELSE '8+ km'
    END AS distance_band,
    COUNT(*) AS deliveries,
    ROUND(SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivery_performance
GROUP BY distance_band
ORDER BY distance_band;


-- ============================================================
-- SECTION 3: CUSTOMER ANALYTICS
-- ============================================================

-- 3.1 Customers by segment
SELECT
    customer_segment,
    COUNT(*)                     AS customers,
    ROUND(AVG(total_orders), 1)  AS avg_orders_per_customer,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value
FROM customers
GROUP BY customer_segment
ORDER BY customers DESC;

-- 3.2 Top 10 customers by lifetime spend (via actual orders, not the stored avg)
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    COUNT(o.order_id)            AS orders_placed,
    ROUND(SUM(o.order_total), 2) AS lifetime_spend
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_segment
ORDER BY lifetime_spend DESC
LIMIT 10;

-- 3.3 Repeat vs one-time customers
SELECT
    CASE WHEN order_count = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS customers
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) t
GROUP BY customer_type;

-- 3.4 Customer registrations over time (growth trend)
SELECT
    DATE_FORMAT(registration_date, '%Y-%m') AS month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;

-- 3.5 Average feedback rating and sentiment breakdown
SELECT
    sentiment,
    COUNT(*)              AS feedback_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM customer_feedback
GROUP BY sentiment
ORDER BY feedback_count DESC;

-- 3.6 Does delivery delay hurt feedback? (join feedback to delivery performance)
SELECT
    dp.delivery_status,
    ROUND(AVG(cf.rating), 2) AS avg_rating,
    COUNT(*)                 AS feedback_count
FROM customer_feedback cf
JOIN delivery_performance dp ON dp.order_id = cf.order_id
GROUP BY dp.delivery_status;

-- 3.7 Top feedback categories (what are people complaining/praising about)
SELECT
    feedback_category,
    COUNT(*) AS mentions,
    ROUND(AVG(rating), 2) AS avg_rating
FROM customer_feedback
GROUP BY feedback_category
ORDER BY mentions DESC;


-- ============================================================
-- SECTION 4: MARKETING ROI
-- ============================================================

-- 4.1 Overall marketing performance summary
SELECT
    ROUND(SUM(spend), 2)             AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(SUM(revenue_generated) / SUM(spend), 2) AS overall_roas,
    SUM(impressions)                 AS total_impressions,
    SUM(clicks)                      AS total_clicks,
    SUM(conversions)                 AS total_conversions,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2)   AS ctr_pct,
    ROUND(SUM(conversions) * 100.0 / SUM(clicks), 2)   AS conversion_rate_pct
FROM marketing_performance;

-- 4.2 ROAS by channel
SELECT
    channel,
    ROUND(SUM(spend), 2)               AS total_spend,
    ROUND(SUM(revenue_generated), 2)   AS total_revenue,
    ROUND(SUM(revenue_generated) / SUM(spend), 2) AS roas
FROM marketing_performance
GROUP BY channel
ORDER BY roas DESC;

-- 4.3 Best performing campaigns by ROAS
SELECT
    campaign_name,
    channel,
    target_audience,
    ROUND(spend, 2)             AS spend,
    ROUND(revenue_generated, 2) AS revenue,
    roas
FROM marketing_performance
ORDER BY roas DESC
LIMIT 10;

-- 4.4 Performance by target audience segment
SELECT
    target_audience,
    ROUND(SUM(spend), 2)             AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(roas), 2)              AS avg_roas
FROM marketing_performance
GROUP BY target_audience
ORDER BY avg_roas DESC;

-- 4.5 Monthly marketing spend vs revenue trend
SELECT
    DATE_FORMAT(date, '%Y-%m')       AS month,
    ROUND(SUM(spend), 2)             AS spend,
    ROUND(SUM(revenue_generated), 2) AS revenue
FROM marketing_performance
GROUP BY month
ORDER BY month;


-- ============================================================
-- SECTION 5: INVENTORY (bonus — ops health)
-- ============================================================

-- 5.1 Products with highest damage rate
SELECT
    p.product_name,
    SUM(i.stock_received)                       AS total_received,
    SUM(i.damaged_stock)                        AS total_damaged,
    ROUND(SUM(i.damaged_stock) * 100.0 / SUM(i.stock_received), 2) AS damage_pct
FROM inventory i
JOIN products p ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name
HAVING total_received > 0
ORDER BY damage_pct DESC
LIMIT 10;
