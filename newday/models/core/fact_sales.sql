{{
    config(
        materialized='incremental',
        tags=['fact', 'sales'],
        unique_key='order_id'
    )
}}

SELECT
    sf.ORDER_ID,
    sf.CUSTOMER_ID,
    sf.PRODUCT_ID,
    sf.ORDER_DATE,
    sf.ORDER_AMOUNT,
    sf.ORDER_QUANTITY,
    sf.PAYMENT_METHOD,
    -- Degenerate dimension
    sf.ORDER_ID AS ORDER_NUMBER,
    -- Additive facts
    sf.ORDER_AMOUNT AS sales_amount,
    sf.DISCOUNT_APPLIED,
    sf.SHIPPING_COST,
    pc.COST_PRICE * (sf.ORDER_AMOUNT / NULLIF(pc.RETAIL_PRICE, 0)) AS cost_amount,
    sf.ORDER_AMOUNT - (pc.COST_PRICE * (sf.ORDER_AMOUNT / NULLIF(pc.RETAIL_PRICE, 0))) AS gross_profit,
    -- Ratios
    CASE 
        WHEN sf.ORDER_AMOUNT > 0 
        THEN (sf.ORDER_AMOUNT - (pc.COST_PRICE * (sf.ORDER_AMOUNT / NULLIF(pc.RETAIL_PRICE, 0)))) / sf.ORDER_AMOUNT 
        ELSE 0 
    END AS gross_margin
FROM {{ ref('stg_sales_fact') }} sf
LEFT JOIN {{ ref('stg_product_categories') }} pc 
    ON sf.PRODUCT_ID = pc.PRODUCT_ID
{% if is_incremental() %}
WHERE sf.ORDER_DATE >= (SELECT MAX(ORDER_DATE) FROM {{ this }})
{% endif %}