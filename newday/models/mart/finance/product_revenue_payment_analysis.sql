{{
    config(
        materialized='table',
        tags=['financial', 'payment', 'enhanced']
    )
}}

WITH revenue_base AS (
    SELECT
        DATE_TRUNC('month', fs.ORDER_DATE) AS month,
        dp.CATEGORY_NAME,
        -- Handle zero quantity by using 1 as default
        CASE 
            WHEN fs.order_quantity = 0 OR fs.order_quantity IS NULL THEN 1
            ELSE fs.order_quantity 
        END AS effective_quantity,
        fs.SALES_AMOUNT,
        fs.payment_method,
        -- Handle null payment methods
        COALESCE(fs.payment_method, 'Unknown') AS payment_method_clean
    FROM {{ ref('fact_sales') }} fs
    LEFT JOIN {{ ref('dim_products') }} dp 
        ON fs.PRODUCT_ID = dp.PRODUCT_ID
    WHERE fs.SALES_AMOUNT > 0
),

payment_totals AS (
    SELECT
        month,
        CATEGORY_NAME,
        payment_method_clean,
        SUM(SALES_AMOUNT) AS revenue_by_payment,
        COUNT(*) AS orders_by_payment
    FROM revenue_base
    GROUP BY 1, 2, 3
),

category_totals AS (
    SELECT
        month,
        CATEGORY_NAME,
        SUM(SALES_AMOUNT) AS total_category_revenue
    FROM revenue_base
    GROUP BY 1, 2
)

SELECT
    pt.month,
    pt.CATEGORY_NAME,
    pt.payment_method_clean AS payment_method,
    pt.revenue_by_payment,
    pt.orders_by_payment,
    ct.total_category_revenue,
    ROUND(
        (pt.revenue_by_payment / NULLIF(ct.total_category_revenue, 0)) * 100, 
        2
    ) AS payment_method_percentage
FROM payment_totals pt
LEFT JOIN category_totals ct 
    ON pt.month = ct.month AND pt.CATEGORY_NAME = ct.CATEGORY_NAME
ORDER BY pt.month DESC, pt.CATEGORY_NAME, pt.revenue_by_payment DESC