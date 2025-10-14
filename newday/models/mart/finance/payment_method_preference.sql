{{
    config(
        materialized='table',
        tags=['financial', 'payment', 'analysis']
    )
}}

WITH payment_stats AS (
    SELECT
        COALESCE(payment_method, 'Unknown') AS payment_method,
        COUNT(DISTINCT ORDER_ID) AS total_orders,
        SUM(SALES_AMOUNT) AS total_revenue,
        AVG(SALES_AMOUNT) AS avg_order_value,
        MIN(SALES_AMOUNT) AS min_order_value,
        MAX(SALES_AMOUNT) AS max_order_value
    FROM {{ ref('fact_sales') }}
    WHERE SALES_AMOUNT > 0
    GROUP BY 1
),

overall_totals AS (
    SELECT
        SUM(total_orders) AS grand_total_orders,
        SUM(total_revenue) AS grand_total_revenue
    FROM payment_stats
)

SELECT
    ps.payment_method,
    ps.total_orders,
    ps.total_revenue,
    ps.avg_order_value,
    ps.min_order_value,
    ps.max_order_value,
    ROUND(
        (ps.total_orders / NULLIF(ot.grand_total_orders, 0)) * 100, 
        2
    ) AS order_percentage,
    ROUND(
        (ps.total_revenue / NULLIF(ot.grand_total_revenue, 0)) * 100, 
        2
    ) AS revenue_percentage,
    -- Payment method effectiveness ratio
    CASE 
        WHEN ps.total_orders > 0 
        THEN ps.total_revenue / ps.total_orders 
        ELSE 0 
    END AS revenue_per_order
FROM payment_stats ps
CROSS JOIN overall_totals ot
ORDER BY ps.total_revenue DESC