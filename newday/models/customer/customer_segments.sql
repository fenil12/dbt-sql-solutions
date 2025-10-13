{{
    config(
        materialized='table',
        tags=['customer', 'segmentation', 'reporting']
    )
}}

WITH customer_order_summary AS (
    SELECT
        c.CUSTOMER_ID,
        c.CUSTOMER_NAME,
        COUNT(DISTINCT s.ORDER_ID) AS NUMBER_OF_ORDERS,
        SUM(s.ORDER_AMOUNT) AS TOTAL_PURCHASE_AMOUNT,
        MIN(s.ORDER_DATE) AS FIRST_ORDER_DATE,
        MAX(s.ORDER_DATE) AS LAST_ORDER_DATE
    FROM {{ ref('stg_customer') }} c
    LEFT JOIN {{ ref('stg_sales_fact') }} s ON c.CUSTOMER_ID = s.CUSTOMER_ID
    GROUP BY c.CUSTOMER_ID, c.CUSTOMER_NAME
)

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    NUMBER_OF_ORDERS,
    TOTAL_PURCHASE_AMOUNT,
    FIRST_ORDER_DATE,
    LAST_ORDER_DATE,
    -- Customer tier segmentation
    CASE
        WHEN TOTAL_PURCHASE_AMOUNT >= 1000 THEN 'High Value'
        WHEN TOTAL_PURCHASE_AMOUNT >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CUSTOMER_TIER,
    -- Days since last order
    CASE 
        WHEN LAST_ORDER_DATE IS NOT NULL 
        THEN DATEDIFF('day', LAST_ORDER_DATE, CURRENT_DATE)
        ELSE NULL
    END AS DAYS_SINCE_LAST_ORDER
FROM customer_order_summary
ORDER BY TOTAL_PURCHASE_AMOUNT DESC