SELECT *
FROM cleaned_Sales
LIMIT 10;

--Overall average order Value

SELECT
ROUND(
    SUM(revenue)::numeric
    / COUNT(DISTINCT order_id),
2
) AS average_order_value
FROM cleaned_sales;


--Monthly  AOV trend
SELECT
month,

ROUND(
    SUM(revenue)::numeric
    / COUNT(DISTINCT order_id),
2
) AS monthly_aov

FROM cleaned_sales
GROUP BY month
ORDER BY month;


--Monthly Gross Profit Margin %
SELECT

month,

ROUND(CAST(SUM(revenue) AS numeric), 2) AS revenue,

ROUND(CAST(SUM(profit) AS numeric), 2) AS total_profit,

ROUND(
    CAST(
        (
            SUM(profit)
            / NULLIF(SUM(revenue), 0)
        ) * 100
    AS numeric),
2
) AS gross_profit_margin_pct

FROM cleaned_sales

GROUP BY month

ORDER BY month;


 -- Product-level profitability ranked by total profit

 SELECT

product_name,

ROUND(CAST(SUM(revenue) AS numeric), 2)
AS total_revenue,

ROUND(CAST(SUM(profit) AS numeric), 2)
AS total_profit,

ROUND(
    CAST(
        (
            SUM(profit)
            / NULLIF(SUM(revenue), 0)
        ) * 100
    AS numeric),
2
) AS profit_margin_pct,

RANK() OVER(
    ORDER BY SUM(profit) DESC
) AS profitability_rank

FROM cleaned_sales

GROUP BY product_name

ORDER BY total_profit DESC;

-- customer purchase frequency 

SELECT

customer_id,

COUNT(DISTINCT order_id)
AS total_orders,

ROUND(
    CAST(SUM(revenue) AS numeric),
2
) AS total_spent

FROM cleaned_sales

GROUP BY customer_id

ORDER BY total_orders DESC;


--customer lifetime value (CLV)

SELECT

customer_id,

MIN(order_date::date)
AS first_purchase,

MAX(order_date::date)
AS last_purchase,

MAX(order_date::date)
-
MIN(order_date::date)
AS customer_lifespan_days,

COUNT(DISTINCT order_id)
AS total_orders,

ROUND(
    CAST(SUM(revenue) AS numeric),
2
) AS customer_lifetime_value

FROM cleaned_sales

GROUP BY customer_id

ORDER BY customer_lifetime_value DESC;


-- Customer Segmentation

WITH customer_revenue AS (

    SELECT

    customer_id,

    SUM(revenue) AS total_revenue

    FROM cleaned_sales

    GROUP BY customer_id
),

percentiles AS (

    SELECT

    PERCENTILE_CONT(0.75)
    WITHIN GROUP (
        ORDER BY total_revenue
    ) AS vip_threshold,

    PERCENTILE_CONT(0.25)
    WITHIN GROUP (
        ORDER BY total_revenue
    ) AS low_threshold

    FROM customer_revenue
)

SELECT

cr.customer_id,

ROUND(
    CAST(cr.total_revenue AS numeric),
2
) AS total_revenue,

CASE

    WHEN cr.total_revenue >= p.vip_threshold
    THEN 'VIP'

    WHEN cr.total_revenue <= p.low_threshold
    THEN 'Low Value'

    ELSE 'Regular'

END AS customer_segment

FROM customer_revenue cr

CROSS JOIN percentiles p

ORDER BY total_revenue DESC;

--Segmentation summary

WITH customer_revenue AS (

    SELECT

    customer_id,

    SUM(revenue) AS total_revenue

    FROM cleaned_sales

    GROUP BY customer_id
),

percentiles AS (

    SELECT

    PERCENTILE_CONT(0.75)
    WITHIN GROUP (
        ORDER BY total_revenue
    ) AS vip_threshold,

    PERCENTILE_CONT(0.25)
    WITHIN GROUP (
        ORDER BY total_revenue
    ) AS low_threshold

    FROM customer_revenue
),

customer_segments AS (

    SELECT

    cr.customer_id,

    cr.total_revenue,

    CASE

        WHEN cr.total_revenue >= p.vip_threshold
        THEN 'VIP'

        WHEN cr.total_revenue <= p.low_threshold
        THEN 'Low Value'

        ELSE 'Regular'

    END AS customer_segment

    FROM customer_revenue cr

    CROSS JOIN percentiles p
)

SELECT

customer_segment,

COUNT(customer_id)
AS total_customers,

ROUND(
    CAST(SUM(total_revenue) AS numeric),
2
) AS segment_revenue,

ROUND(
    CAST(
        (
            SUM(total_revenue)
            / SUM(SUM(total_revenue)) OVER()
        ) * 100
    AS numeric),
2
) AS revenue_contribution_pct

FROM customer_segments

GROUP BY customer_segment

ORDER BY segment_revenue DESC;



--Pareto 80/20 Analysis

WITH customer_revenue AS (

    SELECT

    customer_id,

    SUM(revenue) AS total_revenue

    FROM cleaned_sales

    GROUP BY customer_id
),

ranked_customers AS (

    SELECT

    customer_id,

    total_revenue,

    NTILE(10) OVER(
        ORDER BY total_revenue DESC
    ) AS revenue_decile

    FROM customer_revenue
)

SELECT

CASE

    WHEN revenue_decile IN (1,2)
    THEN 'Top 20% Customers'

    ELSE 'Remaining 80% Customers'

END AS customer_group,

ROUND(
    CAST(SUM(total_revenue) AS numeric),
2
) AS revenue_generated,

ROUND(
    CAST(
        (
            SUM(total_revenue)
            / SUM(SUM(total_revenue)) OVER()
        ) * 100
    AS numeric),
2
) AS revenue_percentage

FROM ranked_customers

GROUP BY customer_group

ORDER BY revenue_generated DESC;