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