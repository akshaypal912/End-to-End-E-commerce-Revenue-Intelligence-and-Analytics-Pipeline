--creating month number column 

ALTER TABLE cleaned_sales
ADD COLUMN month_number INT;

UPDATE cleaned_sales
SET month_number = EXTRACT(MONTH FROM order_date::DATE);


--Monthly revenue trend

SELECT
    month_number,
    month,
    ROUND(SUM(revenue)::NUMERIC, 2) AS monthly_revenue
FROM cleaned_sales
GROUP BY month_number, month
ORDER BY month_number;

-- 3 month  moving average forecast 

SELECT

month,

month_number,

ROUND(
    CAST(SUM(revenue) AS numeric),
2
) AS monthly_revenue,

ROUND(
    CAST(
        AVG(SUM(revenue)) OVER(
            ORDER BY month_number
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )
    AS numeric),
2
) AS moving_avg_forecast

FROM cleaned_sales

GROUP BY month, month_number

ORDER BY month_number;

--revenue growth %

WITH monthly_revenue AS (

    SELECT

    month,
    month_number,

    SUM(revenue) AS revenue

    FROM cleaned_sales

    GROUP BY month, month_number
)

SELECT

month,

ROUND(
    CAST(revenue AS numeric),
2
) AS monthly_revenue,

ROUND(
    CAST(
        LAG(revenue) OVER(
            ORDER BY month_number
        )
    AS numeric),
2
) AS previous_month_revenue,

ROUND(
    CAST(
        (
            (
                revenue
                -
                LAG(revenue) OVER(
                    ORDER BY month_number
                )
            )

            /

            NULLIF(
                LAG(revenue) OVER(
                    ORDER BY month_number
                ),
            0)

        ) * 100
    AS numeric),
2
) AS revenue_growth_pct

FROM monthly_revenue

ORDER BY month_number;


-- forecast insight query 

WITH monthly_revenue AS (

    SELECT

    month,
    month_number,

    SUM(revenue) AS revenue

    FROM cleaned_sales

    GROUP BY month, month_number
)

SELECT

month,

ROUND(
    CAST(revenue AS numeric),
2
) AS monthly_revenue,

CASE

    WHEN revenue >
         LAG(revenue) OVER(
             ORDER BY month_number
         )

    THEN 'Growth'

    WHEN revenue <
         LAG(revenue) OVER(
             ORDER BY month_number
         )

    THEN 'Decline'

    ELSE 'Stable'

END AS revenue_trend

FROM monthly_revenue

ORDER BY month_number;


-- final forecast dataset

WITH monthly_data AS (

    SELECT

    month,
    month_number,

    SUM(revenue) AS revenue

    FROM cleaned_sales

    GROUP BY month, month_number
)

SELECT

month,

ROUND(
    CAST(revenue AS numeric),
2
) AS actual_revenue,

ROUND(
    CAST(
        AVG(revenue) OVER(
            ORDER BY month_number
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
        )
    AS numeric),
2
) AS forecasted_revenue,

ROUND(
    CAST(
        (
            (
                revenue
                -
                LAG(revenue) OVER(
                    ORDER BY month_number
                )
            )

            /

            NULLIF(
                LAG(revenue) OVER(
                    ORDER BY month_number
                ),
            0)

        ) * 100
    AS numeric),
2
) AS growth_percentage

FROM monthly_data

ORDER BY month_number;


select * from cleaned_sales


