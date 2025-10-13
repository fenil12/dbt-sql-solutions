{{
    config(
        materialized='table',
        tags=['dimension', 'customers']
    )
}}

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CUSTOMER_EMAIL,
    START_DATE AS CUSTOMER_SINCE_DATE,
    END_DATE AS CUSTOMER_END_DATE,
    STATUS AS CUSTOMER_STATUS,
    IS_VALID_EMAIL,
    -- Slowly Changing Dimension Type 2 attributes
    START_DATE AS VALID_FROM,
    COALESCE(END_DATE, '9999-12-31') AS VALID_TO,
    CASE WHEN END_DATE IS NULL THEN TRUE ELSE FALSE END AS IS_CURRENT
FROM {{ ref('stg_customer') }}