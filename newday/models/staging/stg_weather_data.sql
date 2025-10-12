{{
    config(
        tags=['staging', 'weather', 'external']
    )
}}

SELECT
    DATE,
    COALESCE(TEMPERATURE, 0) AS TEMPERATURE,
    COALESCE(PRECIPITATION, 0) AS PRECIPITATION,
    CITY,
    -- Weather categorization
    CASE 
        WHEN TEMPERATURE > 25 THEN 'Hot'
        WHEN TEMPERATURE < 5 THEN 'Cold'
        ELSE 'Moderate'
    END AS TEMPERATURE_CATEGORY,
    CASE 
        WHEN PRECIPITATION > 5 THEN 'High Precipitation'
        WHEN PRECIPITATION > 1 THEN 'Moderate Precipitation'
        ELSE 'Low Precipitation'
    END AS PRECIPITATION_CATEGORY
FROM {{ ref('weather_data') }}