# Cleaning Log

| # | Issue | Rows affected | Decision | Why |
|---|---|---|---|---|
| 1 | Non-delivered orders (cancelled, shipped, etc.) | ? | Excluded | Not completed sales |
| 2 | Delivered with no delivery date | ? | Excluded from delivery analysis | Cannot measure delay |
| 3 | Delivery date before purchase date | ? | Excluded | Invalid timestamps |
| 4 | Orders with multiple reviews | ? | Kept latest | Prevent join duplication |
| 5 | Products with no category | ? | Labelled "unknown" | Keep revenue rows |
| 6 | customer_id vs customer_unique_id | 99,441 ids vs ? people | Use unique_id for repeat analysis | customer_id is per order |