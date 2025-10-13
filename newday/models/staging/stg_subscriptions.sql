{{
    config(
        tags=['staging', 'subscriptions']
    )
}}

SELECT
    -- Apply conditional padding: pad only for IDs 1-999, no padding for 1000+
    CASE 
        WHEN CUSTOMER_ID BETWEEN 1 AND 999 THEN 
            'CUST' || LPAD(CAST(CUSTOMER_ID AS VARCHAR), 3, '0')
        ELSE 
            'CUST' || CAST(CUSTOMER_ID AS VARCHAR)
    END AS CUSTOMER_ID,
    SUBSCRIPTION_ID,
    PLAN_TYPE,
    SUBSCRIPTION_START_DATE,
    SUBSCRIPTION_END_DATE,
    COALESCE(MONTHLY_FEE, 0) AS MONTHLY_FEE,
    STATUS,
    -- Subscription analysis fields
    CASE 
        WHEN STATUS = 'Active' AND SUBSCRIPTION_END_DATE > CURRENT_DATE THEN 'Active'
        WHEN STATUS = 'Cancelled' THEN 'Cancelled'
        ELSE 'Expired'
    END AS SUBSCRIPTION_STATUS,
    DATEDIFF('day', SUBSCRIPTION_START_DATE, COALESCE(SUBSCRIPTION_END_DATE, CURRENT_DATE)) AS SUBSCRIPTION_DURATION_DAYS
FROM {{ ref('subscription_data') }}