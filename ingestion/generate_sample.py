"""Generate a small synthetic Olist-shaped dataset so CI can run without the real files."""

import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)
OUT = Path("data/raw")
OUT.mkdir(parents=True, exist_ok=True)

N_CUSTOMERS, N_PRODUCTS, N_SELLERS, N_ORDERS = 200, 50, 20, 400
STATES = ["SP", "RJ", "MG", "RS", "PR"]
CITIES = ["sao paulo", "rio de janeiro", "belo horizonte", "porto alegre", "curitiba"]
CATEGORIES = ["beleza_saude", "informatica_acessorios", "cama_mesa_banho", "esporte_lazer"]
STATUSES = ["delivered"] * 8 + ["shipped", "canceled"]
PAYMENT_TYPES = ["credit_card"] * 6 + ["boleto", "voucher", "debit_card"]


def write(name, header, rows):
    with open(OUT / name, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)


customers = [
    (f"cust_{i:05d}", f"uniq_{i % 150:05d}", f"{random.randint(1000, 99999)}",
     random.choice(CITIES), random.choice(STATES))
    for i in range(N_CUSTOMERS)
]
write("olist_customers_dataset.csv",
      ["customer_id", "customer_unique_id", "customer_zip_code_prefix",
       "customer_city", "customer_state"], customers)

products = [
    (f"prod_{i:05d}", random.choice(CATEGORIES), random.randint(20, 60),
     random.randint(100, 900), random.randint(1, 6), random.randint(100, 5000),
     random.randint(10, 60), random.randint(5, 40), random.randint(5, 40))
    for i in range(N_PRODUCTS)
]
write("olist_products_dataset.csv",
      ["product_id", "product_category_name", "product_name_lenght",
       "product_description_lenght", "product_photos_qty", "product_weight_g",
       "product_length_cm", "product_height_cm", "product_width_cm"], products)

sellers = [
    (f"sell_{i:05d}", f"{random.randint(1000, 99999)}",
     random.choice(CITIES), random.choice(STATES))
    for i in range(N_SELLERS)
]
write("olist_sellers_dataset.csv",
      ["seller_id", "seller_zip_code_prefix", "seller_city", "seller_state"], sellers)

base = datetime(2017, 1, 1)
orders, items, payments, reviews = [], [], [], []

for i in range(N_ORDERS):
    oid = f"order_{i:06d}"
    cust = random.choice(customers)[0]
    status = random.choice(STATUSES)
    purchased = base + timedelta(days=random.randint(0, 500), hours=random.randint(0, 23))
    approved = purchased + timedelta(hours=random.randint(1, 24))
    shipped = approved + timedelta(days=random.randint(1, 5))
    estimated = purchased + timedelta(days=random.randint(10, 25))
    delivered = shipped + timedelta(days=random.randint(1, 15)) if status == "delivered" else ""

    orders.append((
        oid, cust, status,
        purchased.strftime("%Y-%m-%d %H:%M:%S"),
        approved.strftime("%Y-%m-%d %H:%M:%S"),
        shipped.strftime("%Y-%m-%d %H:%M:%S"),
        delivered.strftime("%Y-%m-%d %H:%M:%S") if delivered else "",
        estimated.strftime("%Y-%m-%d %H:%M:%S"),
    ))

    for line in range(1, random.randint(1, 3) + 1):
        items.append((
            oid, line, random.choice(products)[0], random.choice(sellers)[0],
            (shipped + timedelta(days=2)).strftime("%Y-%m-%d %H:%M:%S"),
            round(random.uniform(10, 500), 2), round(random.uniform(5, 40), 2),
        ))

    for seq in range(1, random.randint(1, 2) + 1):
        payments.append((
            oid, seq, random.choice(PAYMENT_TYPES),
            random.randint(1, 10), round(random.uniform(20, 600), 2),
        ))

    reviews.append((
        f"rev_{i:06d}", oid, random.randint(1, 5),
        random.choice(["", "Bom", "Recomendo", "Otimo produto"]),
        random.choice(["", "Entrega rapida", "Produto conforme descrito"]),
        purchased.strftime("%Y-%m-%d %H:%M:%S"),
        (purchased + timedelta(days=3)).strftime("%Y-%m-%d %H:%M:%S"),
    ))

write("olist_orders_dataset.csv",
      ["order_id", "customer_id", "order_status", "order_purchase_timestamp",
       "order_approved_at", "order_delivered_carrier_date",
       "order_delivered_customer_date", "order_estimated_delivery_date"], orders)

write("olist_order_items_dataset.csv",
      ["order_id", "order_item_id", "product_id", "seller_id",
       "shipping_limit_date", "price", "freight_value"], items)

write("olist_order_payments_dataset.csv",
      ["order_id", "payment_sequential", "payment_type",
       "payment_installments", "payment_value"], payments)

write("olist_order_reviews_dataset.csv",
      ["review_id", "order_id", "review_score", "review_comment_title",
       "review_comment_message", "review_creation_date",
       "review_answer_timestamp"], reviews)

write("product_category_name_translation.csv",
      ["product_category_name", "product_category_name_english"],
      [(c, c.replace("_", " ").title()) for c in CATEGORIES])

write("olist_geolocation_dataset.csv",
      ["geolocation_zip_code_prefix", "geolocation_lat", "geolocation_lng",
       "geolocation_city", "geolocation_state"],
      [(f"{random.randint(1000, 99999)}", round(random.uniform(-30, -5), 6),
        round(random.uniform(-55, -35), 6), random.choice(CITIES), random.choice(STATES))
       for _ in range(500)])

print("Sample dataset written to data/raw/")
