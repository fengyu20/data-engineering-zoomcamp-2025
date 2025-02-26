with quarter_revenue as(
    select
        service_type,
        FORMAT_TIMESTAMP('%Y-%Q', pickup_datetime) as year_quarter,
        sum(total_amount) as total_revenue
    from 
        {{ ref('fact_trips') }}
    group by
        service_type, year_quarter
),

last_year_quarter_revenue_table as (
    select 
        service_type,
        year_quarter, 
        total_revenue as current_revenue,
        -- four rows before the current row = last year's same quarter
        lag(total_revenue, 4) over (
            partition by service_type
            order by year_quarter 
        ) as last_year_revenue
    from 
        quarter_revenue
),

revenue_comparison as (
    select 
        service_type,
        year_quarter, 
        current_revenue,
        last_year_revenue,
        -- yoy = (current revenue - last year revenue) / last year revenue
        round (100 * (current_revenue - last_year_revenue) / nullif(last_year_revenue, 0), 2) as yoy
    from 
        last_year_quarter_revenue_table
),

year_of_2020 as (
    select 
        *, 
        ROW_NUMBER() OVER (PARTITION BY service_type ORDER BY yoy DESC) AS rn
    from 
        revenue_comparison
    where 
        year_quarter >= '2020-1' and year_quarter <='2020-4'
)

select 
    service_type, 
    year_quarter,
    yoy,
    rn
from 
    year_of_2020
    

