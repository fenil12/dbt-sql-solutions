{{
    config(
        materialized='table',
        tags=['bridge', 'product_category']
    )
}}

SELECT
    p.PRODUCT_ID,
    p.PRODUCT_CATEGORY_ID AS CATEGORY_ID,
    pc.CATEGORY_NAME,
    pc.SUBCATEGORY,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_product_categories') }} pc 
    ON p.PRODUCT_CATEGORY_ID = pc.CATEGORY_ID
WHERE p.PRODUCT_CATEGORY_ID IS NOT NULL