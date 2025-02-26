select 
    * 
from
    {{ref ('fact_trips')}}
where 
    fare_amount > 0 
    and trip_distance > 0
    and payment_type_description in ('Cash', 'Credit Card')