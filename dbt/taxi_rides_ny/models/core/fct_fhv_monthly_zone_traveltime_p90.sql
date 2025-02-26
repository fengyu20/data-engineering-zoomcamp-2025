with fhv_time_diff as (
    -- add timediff and year-month column
    select 
        *,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration,
        FORMAT_TIMESTAMP('%Y-%m', pickup_datetime) AS year_month
    from 
        {{ref ('dim_fhv_trips')}}
),

fhv_percentile_table as (
    -- add 90 percentile and filter the target year-month
    select 
        *,
        PERCENTILE_CONT(trip_duration, 0.90 ignore nulls) over (
            partition by year_month, PUlocationID, DOlocationID) as p90,
    from
        fhv_time_diff
    where 
        year_month = '2019-11'
), 

pickup_zone_rank as (
    -- add the rank number of each pickup zone
    select 
        pickup_zone,
        dropoff_zone,
        p90,
        ROW_NUMBER() OVER (PARTITION BY pickup_zone ORDER BY p90 DESC) AS rn
    from 
        -- ensure distinct ranking 
        (select distinct pickup_zone, dropoff_zone, p90
        from fhv_percentile_table) as distinct_pickup_zone
    where 
        pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
)

-- display the 2nd dropoff zone
select 
    pickup_zone,
    dropoff_zone,
    p90
from 
    pickup_zone_rank
where 
    rn=2
order by
    pickup_zone, p90 desc