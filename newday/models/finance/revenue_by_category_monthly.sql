{{
    config(
        materialized='table',
        tags=['finance', 'revenue', 'reporting']
    )
}}

WITH sales_with_categories AS (
    SELECT
        s.ORDER_ID,
        s.ORDER_DATE,
        DATE_TRUNC('month', s.ORDER_DATE) AS ORDER_MONTH,
        p.PRODUCT_CATEGORY_ID,
        pc.CATEGORY_NAME,
        s.ORDER_AMOUNT,
        s.ORDER_QUANTITY,
        s.TOTAL_AMOUNT
    FROM {{ ref('stg_sales_fact') }} s
    JOIN {{ ref('stg_products') }} p ON s.PRODUCT_ID = p.PRODUCT_ID
    JOIN {{ ref('stg_product_categories') }} pc ON p.PRODUCT_CATEGORY_ID = pc.CATEGORY_ID
)

SELECT
    ORDER_MONTH,
    PRODUCT_CATEGORY_ID,
    CATEGORY_NAME,
    SUM(ORDER_AMOUNT) AS TOTAL_REVENUE,
    SUM(ORDER_QUANTITY) AS TOTAL_QUANTITY,
    COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS,
    SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT_WITH_SHIPPING,
    -- Average order value
    SUM(ORDER_AMOUNT) / NULLIF(COUNT(DISTINCT ORDER_ID), 0) AS AVG_ORDER_VALUE
FROM sales_with_categories
GROUP BY ORDER_MONTH, PRODUCT_CATEGORY_ID, CATEGORY_NAME
ORDER BY ORDER_MONTH DESC, TOTAL_REVENUE DESC