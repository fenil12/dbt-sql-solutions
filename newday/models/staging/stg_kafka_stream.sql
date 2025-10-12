{{
    config(
        tags=['staging', 'events', 'kafka']
    )
}}

SELECT
    CUSTOMER_ID,
    PRODUCT_ID,
    INTERACTION_TYPE,
    TIMESTAMP,
    DATE(TIMESTAMP) AS EVENT_DATE,
    -- Event categorization
    CASE 
        WHEN INTERACTION_TYPE IN ('purchase') THEN 'Conversion'
        WHEN INTERACTION_TYPE IN ('add_to_cart', 'view') THEN 'Engagement'
        ELSE 'Other'
    END AS EVENT_CATEGORY
FROM {{ ref('kafka_stream') }}