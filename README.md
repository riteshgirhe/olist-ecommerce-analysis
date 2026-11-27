# Olist E-commerce Performance and Customer Behavior Analysis

SQL + Python analysis of 96,470 delivered orders from a Brazilian online marketplace
(Sep 2016 to Aug 2018): revenue trends, delivery performance, review scores, and repeat purchasing.

![Average review score by delivery delay](reports/figures/05_delay_vs_review.png)

## Business Problem
Leadership wants to know what drives revenue, whether late deliveries hurt customer
reviews, and why most customers buy only once.

## Key Findings
Based on 96,470 delivered orders from 93,350 customers and 13,220,249 BRL of item revenue.

- **Growth levelled off in 2018.** Jan-Aug 2018 item revenue was 7,217,172 BRL vs 2,993,277 BRL in Jan-Aug 2017 (+141.1%). But monthly revenue peaked in Nov 2017 (987,648 BRL from 7,288 orders), and no month in 2018 beat it: Jan-Aug 2018 stayed between 826,437 and 977,545 BRL.
- **Almost nobody comes back.** 97.0% of customers placed one order. Only 2,801 of 93,350 customers (3.00%) bought again, so growth comes from new customers.
- **Late delivery wrecks reviews.** 6,534 orders (6.8%) arrived after the estimated date. On-time orders average 4.29 stars vs 2.27 for late ones, and 62.4% of late orders got 1-2 stars vs 9.3% of on-time orders. The score falls with the delay: 3.29 (1-3 days late, 1,852 orders), 2.10 (4-7 days, 1,748), 1.70 (8+ days, 2,781).
- **Delivery problems differ by state.** Sao Paulo (SP) is 38.3% of revenue and delivers in 8.3 days with 4.5% late. Alagoas (AL) has the highest late rate at 21.4% (24.0 days average), then Maranhao (MA, 17.4%) and Sergipe (SE, 15.2%). By volume, though, Rio de Janeiro (RJ) matters most: 12.1% late on 12,350 orders is 1,495 late orders, 22.9% of all late orders in the data. AL, MA, and SE together account for only 261 (4.0%).
- **No category dominates.** health_beauty (1,233,132 BRL), watches_gifts (1,165,899 BRL), and bed_bath_table (1,023,435 BRL) lead, but the top three are only 25.9% of revenue.
- **A few customers hold a lot of value.** High-value one-time buyers are 23.1% of customers (21,566) but 54.7% of order value. The two repeat segments are only 3.0% of customers and 5.7% of order value.

These are associations in historical data, not proven causes.

## Recommendations
1. **Fix delivery where it affects the most orders.** Start with RJ (1,495 late orders) and Bahia (BA, 396 late orders at a 12.2% rate), using regional carrier partnerships or more realistic delivery estimates at checkout. Treat AL, MA, and SE as a second step: the worst rates, but few orders. Even 1-3 days late costs about one star.
2. **Test a second-purchase offer on high-value one-time buyers.** They are 21,566 customers and 54.7% of order value, and almost all are one-time buyers today. Try it on a sample first.
3. **Run a win-back message for lapsing repeat buyers.** The 1,257 "loyal but lapsing" customers average 352.6 days since their last order and about 301 BRL per customer.

## Dataset
Brazilian E-Commerce Public Dataset by Olist (Kaggle): 9 files, 8 used here (the large
geolocation file is not needed). Raw files are not included in this repo. Download them from
Kaggle into `data/raw/`.

## Approach
1. Loaded 8 tables into MySQL with Python (`src/load_data.py`)
2. Cleaned and validated the data, and built one row per delivered order (`notebooks/01`)
3. Answered 6 business questions in SQL: CTEs, window functions, cohort retention (`sql/02`)
4. Explored and visualized results with pandas, matplotlib, and seaborn (`notebooks/02`, `03`)
5. Segmented customers with RFM (`notebooks/04`)

## Key Decisions
- Used only `delivered` orders for revenue and delivery metrics. This excluded 2,963 of 99,441 orders (3.0%), plus 8 delivered orders with no delivery date.
- Used `customer_unique_id` (not `customer_id`) to identify real customers: 93,350 people placed these 96,470 orders.
- Kept the latest review per order to avoid duplicating rows in joins. 646 delivered orders have no review and are left out of review averages only.
- Aggregated items before joining, with assertions checking that no rows were duplicated.
- RFM revenue uses order value (items plus freight, 15,418,395 BRL in total), while other revenue figures use item value only (13,220,249 BRL).
- RFM frequency uses fixed levels, because 97% of customers have exactly one order and quartiles would split identical customers arbitrarily.

## Tech Stack
Python (pandas, SQLAlchemy, matplotlib, seaborn), MySQL 8, Jupyter, Git

## How to Run
1. `pip install -r requirements.txt`
2. Create the database: `CREATE DATABASE olist CHARACTER SET utf8mb4;`
3. Copy `.env.example` to `.env` and add your MySQL password
4. Put the Olist CSV files in `data/raw/`
5. `python src/load_data.py`, then run `sql/01_schema_setup.sql`
6. Run the notebooks in order (01 to 04)

## Project Structure
```
olist-ecommerce-analysis/
  README.md
  requirements.txt
  .env.example
  .gitignore
  notebooks/
    01_data_cleaning.ipynb
    02_exploratory_analysis.ipynb
    03_analysis_and_insights.ipynb
    04_rfm_segmentation.ipynb
  sql/
    01_schema_setup.sql
    02_business_queries.sql
  src/
    load_data.py
    utils.py
  reports/
    cleaning_log.md
    data_dictionary.md
    summary.md
    rfm_segment_summary.csv
    figures/
```

## Limitations
- Historical data (2016-2018) from one marketplace, so the results show the method, not current performance.
- No marketing-cost data, so the recommendations are not ROI-tested.
- The data ends in late August 2018, so the last month may be incomplete, and 2016 volumes are too small to analyze.
- The November 2017 peak is likely seasonal or promotional, but the data does not say.
- The data cannot show why customers do not return.