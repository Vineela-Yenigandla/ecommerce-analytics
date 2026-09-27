import logging
import sys
from pathlib import Path

import duckdb
from pyspark.sql import SparkSession

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-7s | %(message)s",
)
log = logging.getLogger("ingestion")

RAW_DIR = Path("data/raw")
DB_PATH = "ecommerce.duckdb"

SOURCE_FILES = {
    "olist_customers_dataset.csv":            "raw_customers",
    "olist_orders_dataset.csv":               "raw_orders",
    "olist_order_items_dataset.csv":          "raw_order_items",
    "olist_order_payments_dataset.csv":       "raw_order_payments",
    "olist_order_reviews_dataset.csv":        "raw_order_reviews",
    "olist_products_dataset.csv":             "raw_products",
    "olist_sellers_dataset.csv":              "raw_sellers",
    "olist_geolocation_dataset.csv":          "raw_geolocation",
    "product_category_name_translation.csv":  "raw_category_translation",
}


def build_spark() -> SparkSession:
    return (
        SparkSession.builder
        .appName("olist_ingestion")
        .config("spark.sql.session.timeZone", "UTC")
        .config("spark.driver.memory", "2g")
        .getOrCreate()
    )


def load_table(spark, con, file_name: str, table_name: str) -> int:
    path = RAW_DIR / file_name
    if not path.exists():
        log.warning("MISSING  %-30s expected at %s", table_name, path)
        return 0

    df = (
        spark.read
        .option("header", True)
        .option("inferSchema", True)
        .option("multiLine", True)     # review text contains newlines
        .option("escape", '"')         # ...and embedded quotes
        .csv(str(path))
    )

    pdf = df.toPandas()
    con.execute(f"CREATE OR REPLACE TABLE raw.{table_name} AS SELECT * FROM pdf")
    log.info("LOADED   %-30s rows=%-8s cols=%s", table_name, f"{len(pdf):,}", len(pdf.columns))
    return len(pdf)


def main() -> None:
    if not RAW_DIR.exists():
        log.error("Missing %s — see README for the Kaggle download", RAW_DIR)
        sys.exit(1)

    spark = build_spark()
    spark.sparkContext.setLogLevel("WARN")

    con = duckdb.connect(DB_PATH)
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    total = 0
    for file_name, table_name in SOURCE_FILES.items():
        total += load_table(spark, con, file_name, table_name)

    con.close()
    spark.stop()
    log.info("COMPLETE total rows ingested: %s", f"{total:,}")


if __name__ == "__main__":
    main()