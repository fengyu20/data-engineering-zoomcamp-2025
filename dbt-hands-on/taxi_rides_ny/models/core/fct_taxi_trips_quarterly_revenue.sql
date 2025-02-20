SELECT
    service_type,
    FORMAT_TIMESTAMP('%Y-Q%Q', pickup_datetime) AS year_quarter,
    SUM(total_amount) AS total_revenue
FROM {{ ref('fact_trips') }}
WHERE pickup_datetime >= '2019-01-01' and pickup_datetime < '2021-01-01'
GROUP BY service_type, year_quarter
ORDER BY year_quarter

