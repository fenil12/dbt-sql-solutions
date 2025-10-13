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
        WHEN TEMPERATURE < 0 THEN 'Freezing'
        WHEN TEMPERATURE BETWEEN 0 AND 10 THEN 'Cold'
        WHEN TEMPERATURE BETWEEN 11 AND 20 THEN 'Cool'
        WHEN TEMPERATURE BETWEEN 21 AND 30 THEN 'Warm'
        ELSE 'Hot'
    END AS TEMPERATURE_CATEGORY,
    CASE 
        WHEN PRECIPITATION = 0 THEN 'No Rain'
        WHEN PRECIPITATION < 2.5 THEN 'Light Rain'
        WHEN PRECIPITATION < 7.5 THEN 'Moderate Rain'
        ELSE 'Heavy Rain'
    END AS precipitation_category
FROM {{ ref('weather_data') }}