"""Load the Olist CSV files into a local MySQL database."""
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")

DB_PASSWORD = os.getenv("DB_PASSWORD")
if not DB_PASSWORD:
    raise SystemExit("DB_PASSWORD not set. Copy .env.example to .env and edit it.")

DB_URL = URL.create(
    "mysql+pymysql",
    username=os.getenv("DB_USER", "root"),
    password=DB_PASSWORD,
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "3306")),
    database=os.getenv("DB_NAME", "olist"),
    query={"charset": "utf8mb4"},
)

RAW = ROOT / "data" / "raw"
LOAD_GEOLOCATION = False  # about 1M rows and not needed for the main analysis

FILES = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "category_translation",
}

DATE_COLS = {
    "orders": [
        "order_purchase_timestamp", "order_approved_at",
        "order_delivered_carrier_date", "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "order_items": ["shipping_limit_date"],
    "order_reviews": ["review_creation_date", "review_answer_timestamp"],
}


def main():
    engine = create_engine(DB_URL)
    with engine.connect() as conn:  # fail fast if the connection is wrong
        conn.execute(text("SELECT 1"))
    print("Connected to database.\n")

    for fname, table in FILES.items():
        if table == "geolocation" and not LOAD_GEOLOCATION:
            print("geolocation: skipped")
            continue
        path = RAW / fname
        if not path.exists():
            print(f"{table}: FILE NOT FOUND ({path.name})")
            continue
        df = pd.read_csv(path, parse_dates=DATE_COLS.get(table, []))
        df.to_sql(table, engine, if_exists="replace", index=False, chunksize=5000)
        print(f"{table}: {len(df):,} rows loaded")

    print("\nDone.")


if __name__ == "__main__":
    main()