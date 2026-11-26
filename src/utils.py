"""Shared helpers for the Olist project."""

import pandas as pd
import matplotlib.pyplot as plt

import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")


def get_engine():
    url = URL.create(
        "mysql+pymysql",
        username=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        database=os.getenv("DB_NAME", "olist"),
        query={"charset": "utf8mb4"},
    )
    return create_engine(url)


FIG_DIR = ROOT / "reports" / "figures"


def load_orders_clean():
    date_cols = ["order_purchase_timestamp",
                 "order_delivered_customer_date",
                 "order_estimated_delivery_date"]
    return pd.read_sql("SELECT * FROM orders_clean", get_engine(), parse_dates=date_cols)


def save_fig(name):
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    plt.savefig(FIG_DIR / f"{name}.png", dpi=150, bbox_inches="tight")