# Olist E-commerce Performance and Customer Behavior Analysis

SQL + Python analysis of ~100K orders from a Brazilian online marketplace (2016-2018),
covering revenue trends, delivery performance, review scores, and repeat purchasing.

> Status: in progress (data loaded, cleaning and analysis under way)

## Business Problem
Leadership wants to understand what drives revenue, whether late deliveries hurt
customer reviews, and why most customers buy only once.

## Business Questions
1. How have revenue and order volume trended month over month?
2. Which product categories and states drive the most revenue?
3. What share of customers make a repeat purchase?
4. Do late deliveries lead to lower review scores?
5. Which customers are most valuable (RFM segmentation)?
6. What is delivery time by state, and where are the worst delays?

## Dataset
Brazilian E-Commerce Public Dataset by Olist (Kaggle). About 9 related tables.
Raw files are not included in this repo. Download them from Kaggle and place them in `data/raw/`.

## Tech Stack
Python (pandas, SQLAlchemy, matplotlib, seaborn), MySQL 8, Jupyter, Git

## How to Run
1. Clone the repo and install: `pip install -r requirements.txt`
2. Create a MySQL database: `CREATE DATABASE olist CHARACTER SET utf8mb4;`
3. Copy `.env.example` to `.env` and add your MySQL password
4. Put the Olist CSV files in `data/raw/`
5. Load the data: `python src/load_data.py`
6. Run `sql/01_schema_setup.sql`, then open the notebooks in order

## Project Structure
- `sql/` schema setup and business queries
- `notebooks/` cleaning, exploration, and insights
- `src/` data loader and helper functions
- `reports/` summary, data dictionary, and figures

## Key Findings
Coming soon.

## Limitations
Historical data (2016-2018) from a single Brazilian marketplace.