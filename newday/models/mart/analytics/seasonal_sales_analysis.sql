{{
    config(
        materialized='table',
        tags=['analytics', 'seasonal', 'trends']
    )
}}

WITH monthly_sales AS (
    SELECT
        dd.year,
        dd.quarter,
        dd.month,
        dd.month_name,
        dd.season,
        dp.CATEGORY_NAME,
        SUM(fs.SALES_AMOUNT) AS monthly_revenue,
        COUNT(DISTINCT fs.ORDER_ID) AS monthly_orders,
        AVG(fs.SALES_AMOUNT) AS avg_order_value
    FROM {{ ref('fact_sales') }} fs
    LEFT JOIN {{ ref('dim_products') }} dp 
        ON fs.PRODUCT_ID = dp.PRODUCT_ID
    LEFT JOIN {{ ref('dim_date') }} dd 
        ON fs.ORDER_DATE = dd.date_key
    WHERE fs.SALES_AMOUNT > 0
    GROUP BY 1, 2, 3, 4, 5, 6
),

category_quarterly AS (
    SELECT
        CATEGORY_NAME,
        year,
        quarter,
        SUM(monthly_revenue) AS quarterly_revenue,
        LAG(SUM(monthly_revenue)) OVER (
            PARTITION BY CATEGORY_NAME 
            ORDER BY year, quarter
        ) AS prev_quarter_revenue
    FROM monthly_sales
    GROUP BY 1, 2, 3
),

category_stats AS (
    SELECT
        CATEGORY_NAME,
        AVG(monthly_revenue) AS avg_monthly_revenue,
        STDDEV(monthly_revenue) AS stddev_monthly_revenue,
        MIN(monthly_revenue) AS min_monthly_revenue,
        MAX(monthly_revenue) AS max_monthly_revenue
    FROM monthly_sales
    GROUP BY 1
)

SELECT
    ms.*,
    cq.quarterly_revenue,
    -- Quarter-over-quarter growth
    ROUND(
        ((cq.quarterly_revenue - cq.prev_quarter_revenue) / 
         NULLIF(cq.prev_quarter_revenue, 0)) * 100, 
        2
    ) AS qoq_growth_percentage,
    
    -- Coefficient of variation (measure of volatility)
    ROUND(
        (cs.stddev_monthly_revenue / NULLIF(cs.avg_monthly_revenue, 0)) * 100, 
        2
    ) AS coefficient_of_variation,
    
    -- Performance ranking within category
    CASE
        WHEN ms.monthly_revenue = cs.max_monthly_revenue THEN 'Best Month'
        WHEN ms.monthly_revenue = cs.min_monthly_revenue THEN 'Worst Month'
        WHEN ms.monthly_revenue > cs.avg_monthly_revenue THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance_category,
    
    -- Percent of average
    ROUND(
        (ms.monthly_revenue / NULLIF(cs.avg_monthly_revenue, 0)) * 100, 
        2
    ) AS percent_of_avg

FROM monthly_sales ms
LEFT JOIN category_quarterly cq 
    ON ms.CATEGORY_NAME = cq.CATEGORY_NAME 
    AND ms.year = cq.year 
    AND ms.quarter = cq.quarter
LEFT JOIN category_stats cs 
    ON ms.CATEGORY_NAME = cs.CATEGORY_NAME
ORDER BY ms.year DESC, ms.month DESC, ms.CATEGORY_NAME