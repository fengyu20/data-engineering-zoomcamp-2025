-- search for negative results
{% test assert_order_date_later_than_2018(model, column_name) %}

    select 
        *
    from 
        {{ model }}
    where 
        {{ column_name }} < '2018-01-01'

{% endtest %}