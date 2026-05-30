import pandas as pd
import numpy as np
from faker import Faker
import random
import os

# Faker object
fake = Faker()

# Load products data
products_df = pd.read_csv("raw_data/products_raw.csv")

# Number of sales records
num_orders = 5000

sales_data = []

for i in range(num_orders):

    # Random product
    product = products_df.sample(1).iloc[0]

    product_id = product['id']
    product_name = product['title']
    price = product['price']

    # Random quantity
    quantity = random.randint(1, 5)

    # Revenue
    revenue = price * quantity

    # Random date
    order_date = fake.date_between(start_date='-1y', end_date='today')

    # Random customer id
    customer_id = random.randint(1000, 5000)

    sales_data.append({
        "order_id": i + 1,
        "customer_id": customer_id,
        "product_id": product_id,
        "product_name": product_name,
        "quantity": quantity,
        "price": price,
        "revenue": revenue,
        "order_date": order_date
    })

# Convert to DataFrame
sales_df = pd.DataFrame(sales_data)

# Create folder if not exists
os.makedirs("raw_data", exist_ok=True)

# Save CSV
sales_df.to_csv("raw_data/fact_sales.csv", index=False)

print("Sales transactions generated successfully!")
print(sales_df.head())