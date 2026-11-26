USE olist;

-- Step 1: Prepare orders_clean for fast queries
ALTER TABLE orders_clean
    MODIFY order_id VARCHAR(32) NOT NULL,
    MODIFY customer_unique_id VARCHAR(32),
    MODIFY customer_state VARCHAR(5),
    MODIFY purchase_month VARCHAR(7),
    ADD PRIMARY KEY (order_id),
    ADD INDEX idx_oc_uid (customer_unique_id),
    ADD INDEX idx_oc_month (purchase_month);
    

-- Step 2: Reconciliation check (do this first)
-- Both numbers must match. If not, a join is duplicating or dropping rows.
SELECT ROUND(SUM(items_value), 2) AS revenue_orders_clean FROM orders_clean;

SELECT ROUND(SUM(oi.price), 2) AS revenue_from_items
FROM order_items oi
JOIN orders_clean o ON oi.order_id = o.order_id;

-- Step 3: The six business queries
-- Q1: Monthly revenue, orders, and month-over-month growth

WITH monthly AS (
    SELECT purchase_month,
           COUNT(*)                   AS orders,
           ROUND(SUM(items_value), 2) AS revenue
    FROM orders_clean
    GROUP BY purchase_month
)
SELECT purchase_month, orders, revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY purchase_month))
                 / LAG(revenue) OVER (ORDER BY purchase_month), 1) AS mom_growth_pct
FROM monthly
ORDER BY purchase_month;


-- Q2: Top 10 categories by revenue, with share of total

SELECT COALESCE(t.product_category_name_english, 'unknown') AS category,
       COUNT(DISTINCT oi.order_id)                           AS orders,
       ROUND(SUM(oi.price), 2)                               AS revenue,
       ROUND(100 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 1) AS pct_of_revenue,
       RANK() OVER (ORDER BY SUM(oi.price) DESC)             AS revenue_rank
FROM order_items oi
JOIN orders_clean o            ON oi.order_id = o.order_id
JOIN products p                ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY revenue_rank
LIMIT 10;

-- Q3: Revenue and delivery by state

SELECT customer_state,
       COUNT(*)                        AS orders,
       ROUND(SUM(items_value), 2)      AS revenue,
       ROUND(AVG(items_value), 2)      AS avg_order_value,
       ROUND(AVG(delivery_days), 1)    AS avg_delivery_days
FROM orders_clean
GROUP BY customer_state
ORDER BY revenue DESC;

-- Q4: Repeat purchase rate

WITH cust AS (
    SELECT customer_unique_id, COUNT(*) AS n_orders
    FROM orders_clean
    GROUP BY customer_unique_id
)
SELECT COUNT(*)                                  AS customers,
       SUM(n_orders > 1)                         AS repeat_customers,
       ROUND(100 * SUM(n_orders > 1) / COUNT(*), 2) AS repeat_rate_pct
FROM cust;


-- Q5: Do late deliveries hurt reviews?

-- 5a: late vs on time
SELECT IF(is_late = 1, 'Late', 'On time')           AS delivery_status,
       COUNT(*)                                     AS orders,
       ROUND(AVG(review_score), 2)                  AS avg_review,
       ROUND(100 * SUM(review_score <= 2) / COUNT(review_score), 1) AS pct_low_reviews
FROM orders_clean
WHERE review_score IS NOT NULL
GROUP BY is_late;

-- 5b: how the damage grows with the delay
SELECT CASE WHEN delay_days <= 0 THEN '1. On time or early'
            WHEN delay_days <= 3 THEN '2. 1-3 days late'
            WHEN delay_days <= 7 THEN '3. 4-7 days late'
            ELSE '4. 8+ days late' END              AS delay_bucket,
       COUNT(*)                                     AS orders,
       ROUND(AVG(review_score), 2)                  AS avg_review
FROM orders_clean
WHERE review_score IS NOT NULL
GROUP BY delay_bucket
ORDER BY delay_bucket;


-- Q6: Which states have the worst delivery performance?

SELECT customer_state,
       COUNT(*)                        AS orders,
       ROUND(AVG(delivery_days), 1)    AS avg_delivery_days,
       ROUND(100 * AVG(is_late), 1)    AS late_pct
FROM orders_clean
GROUP BY customer_state
HAVING COUNT(*) >= 200
ORDER BY late_pct DESC
LIMIT 10;


WITH first_order AS (
    SELECT customer_unique_id, MIN(purchase_month) AS cohort
    FROM orders_clean
    GROUP BY customer_unique_id
),
activity AS (
    SELECT f.cohort,
           PERIOD_DIFF(REPLACE(o.purchase_month, '-', ''),
                       REPLACE(f.cohort, '-', ''))   AS month_offset,
           COUNT(DISTINCT o.customer_unique_id)      AS active_customers
    FROM orders_clean o
    JOIN first_order f ON o.customer_unique_id = f.customer_unique_id
    GROUP BY f.cohort, month_offset
)
SELECT cohort, month_offset, active_customers
FROM activity
WHERE cohort >= '2017-01' AND month_offset BETWEEN 0 AND 6
ORDER BY cohort, month_offset;