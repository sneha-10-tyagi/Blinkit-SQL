-- -------------------------------------------------------------------------------------
-- Business Insights
-- -------------------------------------------------------------------------------------

-- Which products generate the most revenue per unit of stock capacity?
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    (p.max_stock_level - p.min_stock_level) AS stock_range,
    ROUND(SUM(oi.quantity * oi.unit_price) / NULLIF((p.max_stock_level - p.min_stock_level), 0), 2) AS revenue_per_unit_stock
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.max_stock_level, p.min_stock_level
ORDER BY revenue_per_unit_stock DESC;

-- Which delivery partners have the most consistent delivery performance?
SELECT 
    delivery_partner_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time,
    COALESCE(ROUND(STDDEV(delivery_time_minutes), 2), 0.0) AS delivery_time_stddev
FROM delivery_performance
GROUP BY delivery_partner_id
HAVING COUNT(*) >= 1
ORDER BY delivery_time_stddev ASC
LIMIT 10;

-- What’s the average delivery delay by time of day?
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM promised_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM promised_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM promised_time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delay
FROM delivery_performance
GROUP BY time_of_day
ORDER BY avg_delay DESC;

-- Which orders had the highest cost per item but lowest quantity?
SELECT 
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    ROUND(oi.quantity * oi.unit_price, 2) AS total_order_value
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.quantity <= 2
ORDER BY oi.quantity ASC, oi.unit_price DESC
LIMIT 10;

-- Which products have high margin but low sales?
WITH product_sales AS (
    SELECT 
        oi.product_id,
        p.product_name,
        p.margin_percentage,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM order_items oi
    JOIN products p 
	ON oi.product_id = p.product_id
    GROUP BY oi.product_id, p.product_name, p.margin_percentage
)
SELECT *
FROM product_sales
WHERE margin_percentage > 30 AND total_revenue < 1000
ORDER BY margin_percentage DESC, total_revenue ASC;

-- Deliveries where the delivery effort (order value / distance) wasn't worth the order value
WITH delivery_effort AS (
	SELECT 
		o.order_id, 
		o.order_total,
		dp.distance_km,
		ROUND(o.order_total / NULLIF(dp.distance_km, 0), 2) AS value_per_km
	FROM orders o
	JOIN delivery_performance dp
		ON o.order_id = dp.order_id
),

categorized_effort AS (
	SELECT *,
		CASE 
			WHEN value_per_km < 50 THEN 'Poor'
			WHEN value_per_km BETWEEN 50 AND 90 THEN 'Moderate'
			WHEN value_per_km > 90 THEN 'Efficient'
			ELSE 'Unknown'
		END AS efficiency_bucket
	FROM delivery_effort
	WHERE distance_km > 3 AND order_total < 250
)

SELECT *
FROM categorized_effort
ORDER BY value_per_km ASC;

-- Which products with a short shelf life and high stock levels have low sales performance?
WITH product_sales AS (
  SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.shelf_life_days,
    p.max_stock_level,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold
  FROM products p
  LEFT JOIN order_items oi ON p.product_id = oi.product_id
  GROUP BY p.product_id, p.product_name, p.category, p.shelf_life_days, p.max_stock_level
),
ranked_sales AS (
  SELECT *,
         DENSE_RANK() OVER (ORDER BY total_quantity_sold ASC) AS sales_rank
  FROM product_sales
),
thresholds AS (
  SELECT 
    COUNT(*) AS total_products,
    ROUND(COUNT(*) * 0.25) AS low_sales_threshold  -- bottom 25%
  FROM ranked_sales
),
categorise_products AS (
  SELECT r.*,
         t.low_sales_threshold,
         CASE 
           WHEN r.shelf_life_days <= 5 AND r.max_stock_level > 50 AND r.sales_rank <= t.low_sales_threshold
             THEN 'At-Risk'
           ELSE 'Healthy'
         END AS risk_category
  FROM ranked_sales r
  CROSS JOIN thresholds t
)
SELECT *
FROM categorise_products
WHERE risk_category = 'At-Risk'
ORDER BY sales_rank ASC;

-- Are high value orders given faster delivery?
WITH value_buckets AS (
  SELECT 
    o.order_id,
    o.order_total,
    d.delivery_time_minutes,
    NTILE(4) OVER (ORDER BY o.order_total DESC) AS value_quartile
  FROM orders o
  JOIN delivery_performance d ON o.order_id = d.order_id
)
SELECT 
  value_quartile,
  COUNT(*) AS order_count,
  ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM value_buckets
GROUP BY value_quartile
ORDER BY value_quartile;

-- Stress score for Delivery Partners
WITH delivery_stats AS (
  SELECT 
    delivery_partner_id,
    COUNT(*) AS total_deliveries,
    AVG(delivery_time_minutes) AS avg_delay,
    AVG(distance_km) AS avg_distance
  FROM delivery_performance
  GROUP BY delivery_partner_id
),
stress_scores AS (
  SELECT 
    delivery_partner_id,
    total_deliveries,
    ROUND((avg_delay + avg_distance) / NULLIF(total_deliveries, 0), 2) AS stress_score
  FROM delivery_stats
),
ranked_partners AS (
  SELECT *,
         DENSE_RANK() OVER (ORDER BY stress_score DESC) AS stress_rank,
         NTILE(3) OVER (ORDER BY stress_score DESC) AS stress_band
  FROM stress_scores
)
SELECT 
  delivery_partner_id,
  total_deliveries,
  stress_score,
  stress_rank,
  CASE 
    WHEN stress_band = 1 THEN 'High Stress'
    WHEN stress_band = 2 THEN 'Medium Stress '
    ELSE 'Low Stress '
  END AS stress_category
FROM ranked_partners
ORDER BY stress_score DESC;

-- Who are the top 10% highest spending customers, and what is their average order value?
WITH customer_spending AS (
  SELECT 
    customer_id,
    COUNT(*) AS total_orders,
    SUM(order_total) AS total_spent,
    AVG(order_total) AS avg_order_value
  FROM orders
  GROUP BY customer_id
),
ranked_customers AS (
  SELECT *,
         NTILE(10) OVER (ORDER BY total_spent DESC) AS spend_decile
  FROM customer_spending
)
SELECT 
  customer_id,
  total_orders,
  total_spent,
  ROUND(avg_order_value, 2) AS avg_order_value
FROM ranked_customers
WHERE spend_decile = 1
ORDER BY total_spent DESC;








