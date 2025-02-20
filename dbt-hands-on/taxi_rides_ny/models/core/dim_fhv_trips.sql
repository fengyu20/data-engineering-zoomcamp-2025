with dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
), 
fhv_data as (
    select * from {{ref ('stg_fhv_tripdata')}}
)

select fhv_data.dispatching_base_num, 
    extract(year from fhv_data.pickup_datetime) as year,
    extract(month from fhv_data.pickup_datetime) as month,
    fhv_data.pickup_datetime,
    fhv_data.dropOff_datetime as dropoff_datetime,
    fhv_data.PUlocationID, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    fhv_data.DOlocationID,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    fhv_data.SR_Flag,
    fhv_data.Affiliated_base_number
from fhv_data
inner join dim_zones as pickup_zone
on fhv_data.PUlocationID = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_data.DOlocationID = dropoff_zone.locationid