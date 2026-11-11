-- SUPPLIER RELIABILITY SQL PROJECT ANALYSIS

USE delays_analysis;

-- I am working on a Supplier Reliability & Delivery Delays SQL Project trying to help businesses identify 
-- unreliable suppliers, analyze late deliveries, reduce operational costs, and make better purchasing .
-- decisions using data-driven.

SELECT * 
FROM customers;

SELECT * 
FROM geolocation;

SELECT * 
FROM order_items;

SELECT * 
FROM order_payments;

SELECT * 
FROM order_reviews;

SELECT * 
FROM orders;

SELECT * 
FROM product_category_name_translation;

SELECT * 
FROM products;

SELECT * 
FROM sellers;

-- Check missing values
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_status IS NULL) AS missing_order_status,
    SUM(order_delivered_customer_date IS NULL)
        AS missing_delivery_date,
    SUM(order_estimated_delivery_date IS NULL)
        AS missing_estimated_date
FROM orders;

-- Check missing seller information:
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(seller_id IS NULL) AS missing_seller_id,
    SUM(product_id IS NULL) AS missing_product_id
FROM order_items;

-- Checking duplicate orders
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Question 1: Find sellers with the highest number of late deliveries.
SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS late_deliveries
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date >
        o.order_estimated_delivery_date
GROUP BY oi.seller_id
ORDER BY late_deliveries DESC
LIMIT 10;


-- Question 2: Calculate the on-time delivery rate for each seller.
SELECT
    oi.seller_id,
	ROUND(
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date <=
                 o.order_estimated_delivery_date
            THEN o.order_id
        END) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS on_time_rate

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY on_time_rate DESC;


--  Question 3 on-time delivery rate for each seller is 100.
-- Find the average days late for each seller.
SELECT
    oi.seller_id,
    ROUND(AVG(
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    ), 2) AS average_days_late

FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date >
        o.order_estimated_delivery_date
GROUP BY oi.seller_id
ORDER BY average_days_late DESC;


-- Question 4: Find product categories with the most late deliveries.
SELECT
    p.product_category_name,
    COUNT(DISTINCT o.order_id) AS late_orders
FROM orders o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date >
        o.order_estimated_delivery_date
GROUP BY p.product_category_name
ORDER BY late_orders DESC;


-- Question 5: Analyze late deliveries by month and year.
SELECT
    EXTRACT(YEAR FROM order_delivered_customer_date) AS year,
    EXTRACT(MONTH FROM order_delivered_customer_date) AS month,
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date >
        order_estimated_delivery_date
GROUP BY
    EXTRACT(YEAR FROM order_delivered_customer_date),
    EXTRACT(MONTH FROM order_delivered_customer_date)
ORDER BY year, month;


-- Question 6: Compare delivery delays by seller state.
SELECT
    s.seller_state,
    COUNT(DISTINCT o.order_id) AS late_deliveries
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN sellers AS s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date >
        o.order_estimated_delivery_date
GROUP BY s.seller_state
ORDER BY late_deliveries DESC;


-- Question 7: Identify sellers with high late-delivery rates.
SELECT
    oi.seller_id,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_rate
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY late_delivery_rate DESC;







