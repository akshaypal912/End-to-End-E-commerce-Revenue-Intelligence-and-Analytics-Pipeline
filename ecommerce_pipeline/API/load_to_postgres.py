import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# PostgreSQL credentials
username = "postgres"
password = quote_plus("pal12345@")
host = "127.0.0.1"
port = "2891"
database = "ecommerce_dw"

# Create engine
DATABASE_URL = (
    f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}"
)

engine = create_engine(DATABASE_URL)

# Load CSV files
products_df = pd.read_csv("raw_data/products_raw.csv")
sales_df = pd.read_csv("raw_data/fact_sales.csv")

# Load products table
products_df.to_sql(
    "products_raw",
    engine,
    if_exists="replace",
    index=False
)

# Load sales table
sales_df.to_sql(
    "fact_sales",
    engine,
    if_exists="replace",
    index=False
)

print("Data loaded into PostgreSQL successfully!")