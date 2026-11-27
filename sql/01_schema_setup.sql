
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

-- Row-count check after loading
SELECT 'orders' AS tbl, COUNT(*) AS n FROM orders
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;