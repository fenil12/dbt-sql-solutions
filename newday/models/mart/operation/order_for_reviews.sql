{{
    config(
        materialized='table',
        tags=['operations', 'quality', 'review']
    )
}}

SELECT
    fs.ORDER_ID,
    fs.CUSTOMER_ID,
    dc.CUSTOMER_NAME,
    fs.ORDER_DATE,
    fs.SALES_AMOUNT AS order_amount,
    -- Handle null values for discount and shipping
    COALESCE(fs.discount_applied, 0) AS discount_applied,
    COALESCE(fs.shipping_cost, 0) AS shipping_cost,
    
    -- Business rule flags
    CASE 
        WHEN COALESCE(fs.discount_applied, 0) > 30 THEN 1 
        ELSE 0 
    END AS high_discount_flag,
    
    CASE 
        WHEN COALESCE(fs.shipping_cost, 0) > (fs.SALES_AMOUNT * 0.10) THEN 1 
        ELSE 0 
    END AS high_shipping_flag,
    
    -- Combined risk score
    CASE 
        WHEN COALESCE(fs.discount_applied, 0) > 30 
             AND COALESCE(fs.shipping_cost, 0) > (fs.SALES_AMOUNT * 0.10) 
        THEN 'High Risk'
        WHEN COALESCE(fs.discount_applied, 0) > 30 
             OR COALESCE(fs.shipping_cost, 0) > (fs.SALES_AMOUNT * 0.10) 
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS review_priority,
    
    -- Additional metrics for context
    (COALESCE(fs.discount_applied, 0) / NULLIF(fs.SALES_AMOUNT, 0)) * 100 AS discount_percentage,
    (COALESCE(fs.shipping_cost, 0) / NULLIF(fs.SALES_AMOUNT, 0)) * 100 AS shipping_percentage

FROM {{ ref('fact_sales') }} fs
LEFT JOIN {{ ref('dim_customer') }} dc 
    ON fs.CUSTOMER_ID = dc.CUSTOMER_ID
WHERE 
    (COALESCE(fs.discount_applied, 0) > 30 
     OR COALESCE(fs.shipping_cost, 0) > (fs.SALES_AMOUNT * 0.10))
    -- AND dc.IS_CURRENT = TRUE
ORDER BY 
    CASE review_priority
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        ELSE 3
    END,
    fs.SALES_AMOUNT DESC