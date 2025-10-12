{{
    config(
        tags=['staging', 'products']
    )
}}

SELECT
    PRODUCT_ID,
    PRODUCT_NAME,
    PRODUCT_CATEGORY_ID
FROM {{ ref('product') }}