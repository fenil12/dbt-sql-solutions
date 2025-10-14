{{
    config(
        materialized='table',
        tags=['financial', 'daily', 'revenue']
    )
}}

{% set start_date = var('start_date', '2010-01-01') %}
{% set end_date = var('end_date', '2024-03-31') %}

WITH daily_revenue_base AS (
    SELECT
        fs.ORDER_DATE,
        SUM(fs.SALES_AMOUNT) AS daily_revenue,
        SUM(fs.GROSS_PROFIT) AS daily_gross_profit,
        COUNT(DISTINCT fs.ORDER_ID) AS daily_orders,
        COUNT(DISTINCT fs.CUSTOMER_ID) AS daily_customers,
        AVG(fs.SALES_AMOUNT) AS avg_order_value
    FROM {{ ref('fact_sales') }} fs
    {{ date_range_filter(start_date, end_date) }}
    GROUP BY 1
),

date_series AS (
    SELECT
        date_key AS order_date
    FROM {{ ref('dim_date') }}
    WHERE date_key BETWEEN '{{ start_date }}' AND '{{ end_date }}'
)

SELECT
    ds.order_date,
    COALESCE(drb.daily_revenue, 0) AS daily_revenue,
    COALESCE(drb.daily_gross_profit, 0) AS daily_gross_profit,
    COALESCE(drb.daily_orders, 0) AS daily_orders,
    COALESCE(drb.daily_customers, 0) AS daily_customers,
    COALESCE(drb.avg_order_value, 0) AS avg_order_value,
    -- 7-day moving average for trend analysis
    AVG(COALESCE(drb.daily_revenue, 0)) OVER (
        ORDER BY ds.order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS revenue_7d_ma,
    -- Day-over-day growth
    LAG(COALESCE(drb.daily_revenue, 0)) OVER (ORDER BY ds.order_date) AS prev_day_revenue,
    CASE 
        WHEN LAG(COALESCE(drb.daily_revenue, 0)) OVER (ORDER BY ds.order_date) > 0
        THEN ROUND(
            ((COALESCE(drb.daily_revenue, 0) - 
              LAG(COALESCE(drb.daily_revenue, 0)) OVER (ORDER BY ds.order_date)) / 
             LAG(COALESCE(drb.daily_revenue, 0)) OVER (ORDER BY ds.order_date)) * 100, 
            2
        )
        ELSE NULL
    END AS daily_growth_percentage
FROM date_series ds
LEFT JOIN daily_revenue_base drb 
    ON ds.order_date = drb.order_date
ORDER BY ds.order_date DESC