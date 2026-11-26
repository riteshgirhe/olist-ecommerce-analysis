# Cleaning Log

| # | Issue | Rows affected | Decision | Why |
|---|---|---|---|---|
| 1 | Non-delivered orders (cancelled, shipped, etc.) | 2,963 of 99,441 | Excluded | Not completed sales |
| 2 | Delivered with no delivery date | 8 | Excluded | Cannot measure delay |
| 3 | Delivery date before purchase date | 0 | None needed | Checked, no invalid timestamps |
| 4 | Orders with multiple reviews | 551 extra reviews (99,224 to 98,673) | Kept latest review per order | Prevent join duplication |
| 5 | Products with no category | 610 products | Labelled "unknown" | Keep revenue rows |
| 6 | customer_id vs customer_unique_id | 99,441 ids vs 96,096 people | Use unique_id for repeat analysis | customer_id is created per order |
| 7 | Delivered orders with no review | 646 | Kept, review_score left null | Excluded only from review averages |

**Final table:** orders_clean has 96,470 rows, one per delivered order.
**Delivery:** mean 12.1 days, median 10, max 209 (outlier kept, noted). Late share is 6.8%.