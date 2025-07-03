-- ---------------------------------------------------------
-- Data Exploration
-- ---------------------------------------------------------


-- ---------------------------------------------------------
-- Table : orders
-- ---------------------------------------------------------

-- total orders placed
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- date range of orders placed
SELECT DATE(MIN(promised_delivery_time)) AS first_date ,
		DATE(MAX(promised_delivery_time)) AS last_date 
FROM orders;

-- number of unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- most common mode of payment
SELECT payment_method , COUNT(payment_method)
FROM orders
GROUP BY payment_method
ORDER BY COUNT(payment_method) DESC 
LIMIT 1;

-- comparing promised vs actual delivery time
SELECT order_id,
    EXTRACT(EPOCH FROM (actual_delivery_time - promised_delivery_time))/60 AS delay_minutes
FROM orders;

-- orders per day
SELECT DATE(order_date) AS order_day, COUNT(*)
FROM orders 
GROUP BY order_day
ORDER BY order_day;

-- ---------------------------------------------------------
-- Table : products
-- ---------------------------------------------------

-- number of unique products
SELECT COUNT( DISTINCT product_name) AS unique_products
FROM products;

-- products by category
SELECT category, COUNT(*) 
FROM products 
GROUP BY category 
ORDER BY COUNT(*) DESC;

-- products by brand
SELECT brand, COUNT(*) 
FROM products 
GROUP BY brand
ORDER BY COUNT(*) DESC;

-- products where price is greater than or equal to MRP 
SELECT * 
FROM products 
WHERE price >= mrp;

-- distribution of margin percentage
SELECT 
    width_bucket(margin_percentage, 0, 100, 5) AS margin_bucket,
    COUNT(*) 
FROM products
GROUP BY margin_bucket
ORDER BY margin_bucket;

-- products shelf life distribution by product_name
SELECT product_name , COUNT (shelf_life_days) as shelf_life
FROM products
GROUP BY product_name
ORDER BY COUNT (shelf_life_days) DESC;

-- ---------------------------------------------------------
-- Table : order_items
-- ---------------------------------------------------------

-- total number of order_items
SELECT COUNT(order_id)
FROM order_items;

-- most frequent ordered products 
SELECT product_id , COUNT(product_id)
FROM order_items
GROUP BY product_id
ORDER BY COUNT(product_id) DESC

-- most sold products by quantity
SELECT product_id, SUM(quantity) AS total_quantity
FROM order_items
GROUP BY product_id
ORDER BY total_quantity DESC
LIMIT 10;

-- what quantities are most common while ordering?
SELECT MAX(quantity)
FROM order_items;

-- check for negative unit prices
SELECT unit_price
FROM order_items
WHERE unit_price < 0;

-- check for orphaned order_id (ie order_id not in orders)
SELECT oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- check for orphaned product_id (ie order_id not in products)
SELECT oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ---------------------------------------------------------
-- Table : delivery_performance
-- ---------------------------------------------------------

-- count of orders by delivery status
SELECT delivery_status, COUNT(order_id) AS orders_count
FROM delivery_performance
GROUP BY delivery_status
ORDER BY orders_count;

-- average delivery time (in minutes)
SELECT AVG(delivery_time_minutes) 
FROM delivery_performance;

-- distribution of distance_km
SELECT width_bucket(distance_km, 0, 10, 10) AS distance_bucket, COUNT(*)
FROM delivery_performance
GROUP BY distance_bucket
ORDER BY distance_bucket;

-- delay count by reasons_if_delayed
SELECT reasons_if_delayed , COUNT(*) as frequency
FROM delivery_performance
GROUP BY reasons_if_delayed
ORDER BY reasons_if_delayed;

-- check if negative delivery minutes are correct or not?
SELECT 
    order_id,
    promised_time,
    actual_time,
    delivery_time_minutes AS recorded_minutes,
    ROUND(EXTRACT(EPOCH FROM (actual_time - promised_time)) / 60, 1) AS computed_minutes,
    CASE
        WHEN ROUND(EXTRACT(EPOCH FROM (actual_time - promised_time)) / 60, 1) != delivery_time_minutes THEN 'Mismatch'
        ELSE 'OK'
    END AS status_check
FROM delivery_performance
WHERE delivery_time_minutes < 0;

-- Average delivery time by delivery partner
SELECT delivery_partner_id, ROUND(AVG(delivery_time_minutes), 2) AS avg_time
FROM delivery_performance
GROUP BY delivery_partner_id
ORDER BY avg_time;


-- ---------------------------------------------------------
-- Cross Table Exploration
-- ---------------------------------------------------------

-- average number of items per order
SELECT AVG(item_count) AS avg_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS sub;

-- total quantity and revenue per product
SELECT 
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_name
ORDER BY total_revenue DESC;

-- products with frequent delays
SELECT oi.product_id ,
	   p.product_name,
	   COUNT(*) FILTER (WHERE dp.delivery_status <> 'On Time') AS delay_count
FROM order_items oi
JOIN delivery_performance dp  
ON oi.order_id = dp.order_id
JOIN products p 
ON oi.product_id = p.product_id
WHERE dp.delivery_status <> 'On Time'
GROUP BY oi.product_id, p.product_name
ORDER BY delay_count DESC
LIMIT 10;
		
















