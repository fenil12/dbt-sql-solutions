{{
    config(
        materialized='table',
        tags=['dimension', 'date']
    )
}}

SELECT
    date_day AS date_key,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    DAY(date_day) AS day,
    DAYOFWEEK(date_day) AS day_of_week,
    DAYOFYEAR(date_day) AS day_of_year,
    WEEK(date_day) AS week_of_year,
    MONTHNAME(date_day) AS month_name,
    DAYNAME(date_day) AS day_name,
    CASE 
        WHEN DAYOFWEEK(date_day) IN (1, 2, 3, 4, 5) THEN 'Weekday' 
        ELSE 'Weekend' 
    END AS day_type,
    CASE 
        WHEN MONTH(date_day) IN (11, 12, 1, 2) THEN 'Winter'
        WHEN MONTH(date_day) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(date_day) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    year || '-Q' || quarter AS year_quarter,
    year || '-' || LPAD(month, 2, '0') AS year_month
FROM (
    SELECT
        DATEADD('day', seq4(), '2010-01-01') as date_day
    FROM 
        TABLE(GENERATOR(ROWCOUNT => 365 * 50))
)