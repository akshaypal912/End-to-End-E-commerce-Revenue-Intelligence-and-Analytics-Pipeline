import requests
import pandas as pd
import os

# API URL
url = "https://dummyjson.com/products"

# Request bhejna
response = requests.get(url)

# JSON data lena
data = response.json()

# Products list extract karna
products = data['products']

# DataFrame banana
df = pd.DataFrame(products)

# First 5 rows print karna
print(df.head())

# CSV save karna
os.makedirs("raw_data", exist_ok=True)
df.to_csv("raw_data/products_raw.csv", index=False)

print("Products data fetched successfully!")