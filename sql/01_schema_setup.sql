show databases;

CREATE DATABASE olist CHARACTER SET utf8mb4;

USE olist;

ALTER TABLE orders         MODIFY order_id VARCHAR(32) NOT NULL, MODIFY customer_id VARCHAR(32);
ALTER TABLE customers      MODIFY customer_id VARCHAR(32) NOT NULL, MODIFY customer_unique_id VARCHAR(32);
ALTER TABLE products       MODIFY product_id VARCHAR(32) NOT NULL;
ALTER TABLE sellers        MODIFY seller_id VARCHAR(32) NOT NULL;
ALTER TABLE order_items    MODIFY order_id VARCHAR(32), MODIFY product_id VARCHAR(32), MODIFY seller_id VARCHAR(32);
ALTER TABLE order_payments MODIFY order_id VARCHAR(32);
ALTER TABLE order_reviews  MODIFY order_id VARCHAR(32);

ALTER TABLE orders    ADD PRIMARY KEY (order_id);
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE products  ADD PRIMARY KEY (product_id);
ALTER TABLE sellers   ADD PRIMARY KEY (seller_id);

CREATE INDEX idx_items_order     ON order_items(order_id);
CREATE INDEX idx_items_product   ON order_items(product_id);
CREATE INDEX idx_payments_order  ON order_payments(order_id);
CREATE INDEX idx_reviews_order   ON order_reviews(order_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_customers_uid   ON customers(customer_unique_id);


SELECT 'orders' AS tbl, COUNT(*) AS n FROM orders
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;

-- 1. Order statuses and how common they are
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 2. Date range of the data
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

-- 3. Missing delivery dates (and how they relate to status)
SELECT order_status,
       COUNT(*) AS orders,
       SUM(order_delivered_customer_date IS NULL) AS null_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- 4. Customers vs real people (this is the key trap)
SELECT COUNT(*) AS customer_ids,
       COUNT(DISTINCT customer_unique_id) AS unique_people
FROM customers;

-- 5. Orders with more than one item
SELECT COUNT(*) AS multi_item_orders
FROM (SELECT order_id FROM order_items GROUP BY order_id HAVING COUNT(*) > 1) t;

-- 6. Orders with more than one review (join-duplication risk)
SELECT COUNT(*) AS multi_review_orders
FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1) t;
