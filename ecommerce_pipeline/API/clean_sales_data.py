import pandas as pd
import numpy as np
import os

# Load raw sales data
df = pd.read_csv("raw_data/fact_sales.csv")

print("Original Shape:")
print(df.shape)


# DATA CLEANING


# Remove duplicates
df = df.drop_duplicates()

# Handle missing values
df = df.fillna(0)

# Convert order_date to datetime
df['order_date'] = pd.to_datetime(df['order_date'])


# FEATURE ENGINEERING


# Extract year and month
df['year'] = df['order_date'].dt.year
df['month'] = df['order_date'].dt.month_name()

# Create estimated cost
df['estimated_cost'] = df['revenue'] * 0.6

# Create profit
df['profit'] = df['revenue'] - df['estimated_cost']

# Profit margin
df['profit_margin'] = (
    df['profit'] / df['revenue']
) * 100

# Average order value
df['avg_order_value'] = (
    df['revenue'] / df['quantity']
)


# SORT DATA


df = df.sort_values(by='order_date')


# SAVE CLEANED DATA

os.makedirs("transformed_data", exist_ok=True)

df.to_csv(
    "transformed_data/cleaned_sales_data.csv",
    index=False
)

print("\nCleaned Data Shape:")
print(df.shape)

print("\nData cleaning completed successfully!")
print(df.head())