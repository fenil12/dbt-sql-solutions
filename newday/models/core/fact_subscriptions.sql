{{
    config(
        materialized='table',
        tags=['fact', 'subscriptions']
    )
}}

SELECT
    s.SUBSCRIPTION_ID,
    s.CUSTOMER_ID,
    s.PLAN_TYPE,
    s.SUBSCRIPTION_START_DATE,
    s.SUBSCRIPTION_END_DATE,
    s.STATUS,
    s.SUBSCRIPTION_DURATION_DAYS,
    s.MONTHLY_FEE,
    -- Status flags
    CASE WHEN s.STATUS = 'Active' THEN 1 ELSE 0 END AS is_active_subscription,
    CASE WHEN s.STATUS = 'Cancelled' THEN 1 ELSE 0 END AS is_cancelled_subscription,
FROM {{ ref('stg_subscriptions') }} s