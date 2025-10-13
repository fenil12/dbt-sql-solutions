{{
    config(
        materialized='table',
        tags=['dimension', 'products']
    )
}}

SELECT
    p.PRODUCT_ID,
    p.PRODUCT_NAME,
    p.PRODUCT_CATEGORY_ID,
    pc.CATEGORY_NAME,
    pc.SUBCATEGORY,
    pc.BRAND,
    pc.SUPPLIER_ID,
    pc.COST_PRICE,
    pc.RETAIL_PRICE,
    pc.MARGIN_PERCENT,
    pc.PROFIT_MARGIN,
    pc.STOCK_LEVEL,
    pc.REORDER_POINT,
    pc.INVENTORY_STATUS,
    pc.DISCONTINUED,
    pc.LAUNCH_DATE,
    -- Product lifecycle attributes
    CASE 
        WHEN pc.DISCONTINUED THEN 'Discontinued'
        WHEN pc.STOCK_LEVEL = 0 THEN 'Out of Stock'
        WHEN pc.STOCK_LEVEL <= pc.REORDER_POINT THEN 'Low Stock'
        ELSE 'Available'
    END AS PRODUCT_STATUS,
    DATEDIFF(day, pc.LAUNCH_DATE, CURRENT_DATE) AS DAYS_SINCE_LAUNCH
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_product_categories') }} pc 
    ON p.PRODUCT_ID = pc.PRODUCT_ID