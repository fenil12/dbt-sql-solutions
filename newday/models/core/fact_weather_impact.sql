{{
    config(
        materialized='table',
        tags=['fact', 'weather', 'conformed']
    )
}}

SELECT
    w.DATE AS weather_date,
    w.TEMPERATURE,
    w.PRECIPITATION,
    w.CITY,
    w.TEMPERATURE_CATEGORY,
    w.PRECIPITATION_CATEGORY
FROM {{ ref('stg_weather_data') }} w