with order_amount as (
    select
        order_id,
        -- case when
        sum (case when status = 'success' then amount end) as amount
    from 
        {{ ref('stg_stripe__payments')}}
    group by
        order_id
),

customer_amount as (
    select 
        order_table.customer_id,
        order_amount.order_id,
        order_table.order_date,
        -- coalesc
        coalesce (order_amount.amount, 0) as amount
    from 
        {{ ref('stg_jaffle_shop__orders') }} as order_table
    left join 
        order_amount on order_table.order_id = order_amount.order_id
)

select * from customer_amount



