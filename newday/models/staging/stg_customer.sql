{{
    config(
        tags=['staging', 'customers']
    )
}}

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CUSTOMER_EMAIL,
    START_DATE,
    END_DATE,
    STATUS,
    -- Data quality checks
    CASE 
        WHEN CUSTOMER_EMAIL IS NOT NULL AND CUSTOMER_EMAIL LIKE '%@%' THEN 1 
        ELSE 0 
    END AS IS_VALID_EMAIL
FROM {{ ref('customer') }}