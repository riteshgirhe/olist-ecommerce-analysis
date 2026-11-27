USE olist;

-- 1. Order statuses and how common they are
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 2. Date range of the data
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

-- 3. Missing delivery dates by status
SELECT order_status,
       COUNT(*) AS orders,
       SUM(order_delivered_customer_date IS NULL) AS null_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 4. Customers vs real people (the key trap)
SELECT COUNT(*) AS customer_ids,
       COUNT(DISTINCT customer_unique_id) AS unique_people
FROM customers;

-- 5. Orders with more than one item
SELECT COUNT(*) AS multi_item_orders
FROM (SELECT order_id FROM order_items GROUP BY order_id HAVING COUNT(*) > 1) t;

-- 6. Orders with more than one review (join-duplication risk)
SELECT COUNT(*) AS multi_review_orders
FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1) t;