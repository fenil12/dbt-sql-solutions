{{
    config(
        materialized='incremental',
        tags=['fact', 'events', 'customer_behavior'],
        unique_key='event_id'
    )
}}

SELECT
    -- Let Snowflake handle the unique ID automatically
    ROW_NUMBER() OVER (ORDER BY ks.TIMESTAMP, ks.CUSTOMER_ID, ks.PRODUCT_ID) AS event_id,
    ks.CUSTOMER_ID,
    ks.PRODUCT_ID,
    ks.TIMESTAMP,
    ks.EVENT_DATE,
    ks.INTERACTION_TYPE,
    ks.EVENT_CATEGORY,
    -- Event sequence facts
    ROW_NUMBER() OVER (PARTITION BY ks.CUSTOMER_ID ORDER BY ks.TIMESTAMP) AS customer_event_sequence,
    -- Session identification (simplified)
    ks.CUSTOMER_ID || '_' || TO_DATE(ks.TIMESTAMP) AS session_id,
    -- Time-based facts
    EXTRACT(HOUR FROM ks.TIMESTAMP) AS hour_of_day,
    -- Fact indicators
    CASE WHEN EVENT_CATEGORY = 'Conversion' THEN 1 ELSE 0 END AS is_conversion,
    CASE WHEN EVENT_CATEGORY = 'Engagement' THEN 1 ELSE 0 END AS is_engagement
FROM {{ ref('stg_kafka_stream') }} ks
{% if is_incremental() %}
WHERE TIMESTAMP >= (SELECT MAX(TIMESTAMP) FROM {{ this }})
{% endif %}