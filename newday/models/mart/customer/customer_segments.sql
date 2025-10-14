{{
    config(
        materialized='table',
        tags=['customer', 'segmentation']
    )
}}

WITH customer_metrics AS (
    SELECT
        dc.CUSTOMER_ID,
        dc.CUSTOMER_NAME,
        dc.CUSTOMER_EMAIL,
        COUNT(DISTINCT fs.ORDER_ID) AS total_orders,
        SUM(fs.SALES_AMOUNT) AS total_purchase_amount,
        AVG(fs.SALES_AMOUNT) AS avg_order_value,
        MIN(fs.ORDER_DATE) AS first_order_date,
        MAX(fs.ORDER_DATE) AS last_order_date
    FROM {{ ref('dim_customer') }} dc
    LEFT JOIN {{ ref('fact_sales') }} fs 
        ON dc.CUSTOMER_ID = fs.CUSTOMER_ID
    -- WHERE dc.IS_CURRENT = TRUE
    GROUP BY 1, 2, 3
),

customer_segments AS (
    SELECT
        *,
        CASE
            WHEN total_purchase_amount >= 1000 THEN 'High Value'
            WHEN total_purchase_amount >= 500 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_tier,
        DATEDIFF('day', first_order_date, last_order_date) AS customer_lifetime_days
    FROM customer_metrics
)

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CUSTOMER_EMAIL,
    total_orders,
    total_purchase_amount,
    avg_order_value,
    customer_tier,
    first_order_date,
    last_order_date,
    customer_lifetime_days,
    CASE 
        WHEN customer_lifetime_days > 0 
        THEN total_purchase_amount / customer_lifetime_days 
        ELSE 0 
    END AS daily_spend_rate
FROM customer_segments
ORDER BY total_purchase_amount DESC