with unioned_trips as (
    -- combind green and yello trips
    select 
        *, 'Green' as service_type
    from 
        {{ ref('stg_green_tripdata') }}
    union all
    select 
        *, 'Yellow' as service_type
    from 
        {{ ref('stg_yellow_tripdata') }}
),
filtered_trips as (
    -- filter trips
    select *
    from unioned_trips
    where fare_amount > 0
      and trip_distance > 0
      and payment_type_description in ('Cash', 'Credit Card')
),
month_fare as (
    -- add year month column
    select
        *,
        FORMAT_TIMESTAMP('%Y-%m', pickup_datetime) AS year_month,
    from 
        filtered_trips
), 
percentile_month_fare as (
    -- bigquery percentile function: https://cloud.google.com/bigquery/docs/reference/standard-sql/navigation_functions#percentile_disc
    select 
        service_type,
        year_month,
        PERCENTILE_CONT(fare_amount, 1) over (
            partition by service_type, year_month) as max_fare, 
        PERCENTILE_CONT(fare_amount, 0.97) over (
            partition by service_type, year_month) as p97, 
        PERCENTILE_CONT(fare_amount, 0.95) over (
            partition by service_type, year_month) as p95, 
        PERCENTILE_CONT(fare_amount, 0.90) over (
            partition by service_type, year_month) as p90
    from 
        month_fare
)

select 
    distinct service_type, 
    max_fare,
    p97, p95, p90
from 
    percentile_month_fare
where 
    year_month = '2020-04'
