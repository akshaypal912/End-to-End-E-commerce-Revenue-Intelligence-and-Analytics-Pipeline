import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# PostgreSQL credentials
username = "postgres"
password = quote_plus("pal12345@")
host = "127.0.0.1"
port = "2891"
database = "ecommerce_dw"

# Create connection
DATABASE_URL = (
    f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}"
)

engine = create_engine(DATABASE_URL)

# Load cleaned data
df = pd.read_csv(
    "transformed_data/cleaned_sales_data.csv"
)

# Load into PostgreSQL
df.to_sql(
    "cleaned_sales",
    engine,
    if_exists="replace",
    index=False
)

print("Cleaned data loaded successfully!")