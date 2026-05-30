# 🛒 End-to-End E-Commerce Revenue Intelligence & Analytics Pipeline

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-Analytics-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)
![ETL](https://img.shields.io/badge/ETL-Pipeline-8A2BE2?style=flat&logo=apacheairflow&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-1D9E75?style=flat)

A production-style data analytics pipeline that fetches real e-commerce product data via REST API, generates synthetic sales transactions, loads them into a PostgreSQL data warehouse, performs advanced SQL analytics, and visualizes revenue intelligence through an interactive Power BI dashboard — complete with time-series forecasting.

---

## 📌 Project Overview

This project simulates a real-world business intelligence workflow from raw data ingestion to executive-level dashboard reporting. It covers the complete analytics stack — data engineering, SQL analytics, business KPIs, customer segmentation, and revenue forecasting.

**Dataset:** 5,000 synthetic sales transactions | 30 products | 2,859 unique customers | May 2025 – May 2026

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        ETL PIPELINE                         │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   EXTRACT    │───▶│  TRANSFORM   │───▶│     LOAD     │  │
│  │              │    │              │    │              │  │
│  │ REST API     │    │ Data Clean   │    │ PostgreSQL   │  │
│  │ JSON fetch   │    │ Feature Eng  │    │ Data Warehouse│ │
│  │ Raw CSV save │    │ Synthetic    │    │ Structured   │  │
│  │              │    │ Sales Gen    │    │ Tables       │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
              ┌───────────────────────────────┐
              │       ANALYTICS LAYER         │
              │  SQL + Window Functions + RFM │
              └───────────────────────────────┘
                              ↓
              ┌───────────────────────────────┐
              │      FORECASTING LAYER        │
              │           3 months │
              └───────────────────────────────┘
                              ↓
              ┌───────────────────────────────┐
              │     VISUALIZATION LAYER       │
              │  Power BI Dashboard — 4 Pages │
              └───────────────────────────────┘
```

---

## 🔄 ETL Pipeline — Detailed Breakdown

### 🟦 EXTRACT — Data Ingestion
| Step | What Happens |
|---|---|
| REST API Call | Python `requests` fetches product catalogue (name, price, category, ID) from public e-commerce API |
| JSON Parsing | Raw API response parsed, normalized into tabular format |
| Raw Data Save | Stored as CSV in `data/raw/` — immutable source of truth |
| Synthetic Sales | 5,000 sales transactions generated using product IDs from API |

```python
# Extract — REST API call
import requests, pandas as pd

response = requests.get("https://api.example.com/products")
products = pd.DataFrame(response.json())
products.to_csv("data/raw/products_raw.csv", index=False)
```

### 🟨 TRANSFORM — Data Cleaning & Feature Engineering
| Step | What Happens |
|---|---|
| Null handling | Dropped/filled missing values in price, product_name |
| Type casting | `order_date` → datetime, `price/revenue` → float |
| Feature engineering | Added `estimated_cost` (60% of revenue), `profit`, `profit_margin`, `avg_order_value` |
| Date enrichment | Extracted `year`, `month` from `order_date` |
| Deduplication | Removed duplicate `order_id` entries |
| Validation | Checked for negative revenue/profit values |

```python
# Transform — feature engineering
df['estimated_cost']  = df['revenue'] * 0.60
df['profit']          = df['revenue'] - df['estimated_cost']
df['profit_margin']   = (df['profit'] / df['revenue']) * 100
df['avg_order_value'] = df['revenue'] / df['quantity']
df['year']            = pd.to_datetime(df['order_date']).dt.year
df['month']           = pd.to_datetime(df['order_date']).dt.strftime('%B')
```

### 🟩 LOAD — PostgreSQL Data Warehouse
| Step | What Happens |
|---|---|
| DB Connection | Connected to PostgreSQL using `psycopg2` + `SQLAlchemy` |
| Table creation | Created `cleaned_sales_data` table with proper data types |
| Bulk load | Loaded 5,000 rows using `df.to_sql()` with `if_exists='replace'` |
| Indexing | Added index on `order_date`, `customer_id` for query performance |
| Verification | Row count check post-load to confirm data integrity |

```python
# Load — PostgreSQL
from sqlalchemy import create_engine

engine = create_engine("postgresql://user:password@localhost:5432/ecommerce_db")
df.to_sql("cleaned_sales_data", engine, if_exists="replace", index=False)
print(f"Loaded {len(df)} rows successfully")
```

---

## 🔧 Tech Stack

| Layer | Technology |
|---|---|
| Data Ingestion (Extract) | Python, REST API, Requests |
| Data Processing (Transform) | Pandas, NumPy |
| Data Storage (Load) | PostgreSQL 15, SQLAlchemy, psycopg2 |
| Analytics | Advanced SQL, Window Functions |
| Forecasting | Prophet / Statsmodels |
| Visualization | Power BI Desktop, DAX |
| Version Control | Git, GitHub |

---

## 📂 Project Structure

```
Ecommerce-Revenue-Analytics-Pipeline/
│
├── data/
│   ├── cleaned_data.csv
│   ├── forecasting_dataset.csv
│
├── sql/
│   ├── data_cleaning.sql
│   ├── kpi_analysis.sql
│   ├── revenue_trends.sql
│   ├── window_functions.sql
│
├── python/
│   ├── revenue_forecasting.ipynb
│   ├── forecasting_model.py
│
├── dashboard/
│   ├── Ecommerce_Revenue_Dashboard.pbix
│   ├── dashboard_screenshots/
│
├── presentation/
│   ├── project_report.pdf
│
├── README.me
```

---

## 🚀 Pipeline Steps

### Step 1 — REST API Integration
Fetched real product data (names, prices, categories) from a public e-commerce REST API using Python `requests` library. Stored raw JSON responses locally.

### Step 2 — Synthetic Sales Generation
Generated 5,000 realistic sales transactions with randomized customer IDs, quantities, order dates, and revenue figures. Added derived columns: `estimated_cost`, `profit`, `profit_margin`, `avg_order_value`.

### Step 3 — PostgreSQL Data Warehouse
Loaded cleaned data into PostgreSQL using `psycopg2`. Created structured tables for analytics querying.

### Step 4 — SQL Analytics
Wrote 20+ SQL queries covering:
- Revenue & profit aggregations
- Monthly/yearly trend analysis
- Product performance ranking
- Customer lifetime value (CLV)
- RFM segmentation
- Window functions: `LAG()`, `RANK()`, `SUM() OVER`

### Step 5 — Forecasting
Built a time-series revenue forecast using Prophet/ARIMA. Generated 12-month actual vs forecasted comparison with month-over-month growth percentages.

### Step 6 — Power BI Dashboard
5-page interactive dashboard connected to the data files:
- **Page 1** — Revenue Overview (KPI cards, monthly trend, YoY comparison)
- **Page 2** — Product Performance (Top/bottom 10, scatter chart, margin table)
- **Page 3** — Customer Analytics (CLV, segments, RFM, new vs returning)
- **Page 4** — Forecast vs Actual (dual line chart, growth %, clustered bar)
- **Page 5** — KPI Scorecard (executive summary)

---

## 📊 Business Insights & Executive Summary

### 💰 Revenue Performance
| Metric | Value |
|---|---|
| Total Revenue | ₹3.35M |
| Total Profit | ₹1.34M |
| Total Orders | 5,000 |
| Average Order Value | ₹670.90 |
| Profit Margin | ~40% |

### 📈 Revenue Trend Insights
- Revenue **peaked in July** (~₹3,70,000) — highest performing month of the year
- **March and November** recorded the lowest revenue — potential low-demand periods
- Revenue exhibits **clear seasonal fluctuations** throughout the year, suggesting demand cycles tied to product categories

### 🛍️ Top Product Insights
- **Annibale Colombo Sofa** is the top-selling product by revenue
- **Top 5 products generate the majority of total revenue** — high sales concentration
- Sales are concentrated in a few high-value products — Pareto principle holds

### 🪑 Product Strategy
- **Furniture products dominate revenue generation** — sofas, beds, and chairs are the primary business drivers
- Expanding the furniture portfolio has strong potential to increase overall revenue
- Low-cost products (under ₹10) contribute high volume but low revenue impact

### 🔮 Forecast Insight
| Metric | Value |
|---|---|
| Forecasted Revenue (12 months) | ₹3.34M |
| Actual Revenue (12 months) | ₹3.35M |
| Forecast Accuracy | ~99.7% |

- Future revenue is expected to **remain stable under current conditions**
- Forecast closely matches actuals — model reliability is high
- Introducing additional business variables (promotions, seasonality flags) could further improve forecast precision

### 💡 Business Recommendations
1. **Increase inventory** for top-selling furniture products to meet consistent demand
2. **Launch targeted promotions** during low-performing months (March, November) to boost revenue
3. **Reduce revenue concentration risk** — diversify product mix beyond top 5 products
4. **Improve forecasting model** by incorporating external variables like discount rates, marketing spend, and seasonal events

---

## 📈 SQL Highlights

```sql
-- RFM Customer Segmentation
WITH rfm_scores AS (
    SELECT
        customer_id,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
)
SELECT customer_id,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Potential Loyalists'
        ELSE 'At Risk / Lost'
    END AS rfm_segment
FROM rfm_scores;
```

```sql
-- Month-over-Month Revenue Growth using LAG()
SELECT month, monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month_date) AS prev_month,
    ROUND(100.0 * (monthly_revenue - LAG(monthly_revenue)
        OVER (ORDER BY month_date))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY month_date), 0), 2
    ) AS mom_growth_pct
FROM monthly_revenue_cte;
```

---

## ⚙️ How to Run

### Prerequisites
```bash
pip install pandas numpy psycopg2-binary requests prophet sqlalchemy
```

### Setup
```bash
# 1. Clone the repo
git clone https://github.com/yourusername/ecommerce-analytics-pipeline.git
cd ecommerce-analytics-pipeline

# 2. Set up PostgreSQL
createdb ecommerce_db
psql -d ecommerce_db -f sql/sql_analytics.sql

# 3. Run notebooks in order
jupyter notebook notebooks/
```

### Power BI
Open `powerbi/ecommerce_dashboard.pbix` in Power BI Desktop. Update the data source path to your local `data/` folder if prompted.

---

## 📸 Dashboard Screenshots

> Add screenshots here after publishing Power BI dashboard.

| Page | Preview |
|---|---|
| Revenue Overview | `screenshots/page1_revenue_overview.png` |
| Product Performance | `screenshots/page2_products.png` |
| Customer Analytics | `screenshots/page3_customers.png` |
| Forecast vs Actual | `screenshots/page4_forecast.png` |

---

## 🎯 Skills Demonstrated

`Python` `REST API` `ETL Pipeline` `Data Engineering` `PostgreSQL` `SQLAlchemy`
`Advanced SQL` `Window Functions` `RFM Analysis` `Customer Segmentation`
`Time-Series Forecasting` `Power BI` `DAX` `Data Storytelling`

---

## 👤 Author

**Your Name**
- LinkedIn: [linkedin.com/in/yourprofile](https://www.linkedin.com/in/akshay-pal-aa7944322/)
- GitHub: [github.com/yourusername](https://github.com/akshaypal912)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
