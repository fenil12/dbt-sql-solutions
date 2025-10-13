{{
    config(
        materialized='table',
        tags=['finance', 'payment', 'reporting']
    )
}}

WITH sales_with_categories AS (
    SELECT
        DATE_TRUNC('month', s.ORDER_DATE) AS ORDER_MONTH,
        pc.CATEGORY_NAME,
        s.PAYMENT_METHOD,
        s.ORDER_AMOUNT,
        s.ORDER_QUANTITY,
        s.ORDER_ID
    FROM {{ ref('stg_sales_fact') }} s
    JOIN {{ ref('stg_products') }} p ON s.PRODUCT_ID = p.PRODUCT_ID
    JOIN {{ ref('stg_product_categories') }} pc ON p.PRODUCT_CATEGORY_ID = pc.CATEGORY_ID
    -- Handle edge case: exclude orders with zero quantity after our staging transformation
    WHERE s.ORDER_QUANTITY > 0
),

category_monthly_totals AS (
    SELECT
        ORDER_MONTH,
        CATEGORY_NAME,
        SUM(ORDER_AMOUNT) AS CATEGORY_MONTHLY_REVENUE
    FROM sales_with_categories
    GROUP BY ORDER_MONTH, CATEGORY_NAME
),

payment_method_totals AS (
    SELECT
        ORDER_MONTH,
        CATEGORY_NAME,
        PAYMENT_METHOD,
        SUM(ORDER_AMOUNT) AS PAYMENT_METHOD_REVENUE,
        COUNT(DISTINCT ORDER_ID) AS ORDER_COUNT,
        SUM(ORDER_QUANTITY) AS TOTAL_QUANTITY
    FROM sales_with_categories
    GROUP BY ORDER_MONTH, CATEGORY_NAME, PAYMENT_METHOD
)

SELECT
    pm.ORDER_MONTH,
    pm.CATEGORY_NAME,
    pm.PAYMENT_METHOD,
    pm.PAYMENT_METHOD_REVENUE,
    pm.ORDER_COUNT,
    pm.TOTAL_QUANTITY,
    cm.CATEGORY_MONTHLY_REVENUE,
    -- Percentage of sales by payment method within category
    ROUND(
        (pm.PAYMENT_METHOD_REVENUE / NULLIF(cm.CATEGORY_MONTHLY_REVENUE, 0)) * 100, 
        2
    ) AS PAYMENT_METHOD_PERCENTAGE,
    -- Average order value by payment method
    ROUND(
        pm.PAYMENT_METHOD_REVENUE / NULLIF(pm.ORDER_COUNT, 0), 
        2
    ) AS AVG_ORDER_VALUE_BY_PAYMENT
FROM payment_method_totals pm
JOIN category_monthly_totals cm 
    ON pm.ORDER_MONTH = cm.ORDER_MONTH 
    AND pm.CATEGORY_NAME = cm.CATEGORY_NAME
ORDER BY pm.ORDER_MONTH DESC, pm.CATEGORY_NAME, pm.PAYMENT_METHOD_REVENUE DESC