{{
    config(
        tags=['staging', 'sales']
    )
}}

SELECT
    ORDER_ID,
    PRODUCT_ID,
    CUSTOMER_ID,
    ORDER_DATE,
    -- Handle edge cases for order_quantity
    CASE 
        WHEN ORDER_QUANTITY IS NULL OR ORDER_QUANTITY = 0 THEN 1
        ELSE ORDER_QUANTITY 
    END AS ORDER_QUANTITY,
    -- Handle null values in amounts
    COALESCE(ORDER_AMOUNT, 0) AS ORDER_AMOUNT,
    COALESCE(DISCOUNT_APPLIED, 0) AS DISCOUNT_APPLIED,
    COALESCE(SHIPPING_COST, 0) AS SHIPPING_COST,
    PAYMENT_METHOD,
    CREATED_AT,
    -- Calculate derived fields
    ORDER_AMOUNT + COALESCE(SHIPPING_COST, 0) AS TOTAL_AMOUNT,
    CASE 
        WHEN ORDER_AMOUNT > 0 THEN ROUND((COALESCE(DISCOUNT_APPLIED, 0) / ORDER_AMOUNT) * 100, 3)
        ELSE 0 
    END AS DISCOUNT_PERCENTAGE
FROM {{ ref('sales_fact') }}