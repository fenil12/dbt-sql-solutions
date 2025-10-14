{{
    config(
        materialized='table',
        tags=['financial', 'product', 'monthly']
    )
}}

SELECT
    DATE_TRUNC('month', fs.ORDER_DATE) AS month,
    dp.CATEGORY_NAME,
    dp.SUBCATEGORY,
    SUM(fs.SALES_AMOUNT) AS total_revenue,
    SUM(fs.GROSS_PROFIT) AS total_gross_profit,
    AVG(fs.GROSS_MARGIN) AS avg_gross_margin,
    COUNT(DISTINCT fs.ORDER_ID) AS order_count
FROM {{ ref('fact_sales') }} fs
LEFT JOIN {{ ref('dim_products') }} dp 
    ON fs.PRODUCT_ID = dp.PRODUCT_ID
WHERE fs.SALES_AMOUNT > 0
GROUP BY 1, 2, 3
ORDER BY 1 DESC, 2, 3