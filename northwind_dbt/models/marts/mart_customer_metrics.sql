
with orders as (
    select 
        *
    from 
        {{ ref('fct_orders') }}
),

base as (
    select
        order_id,
        customer_id,
        order_date,
        total_amount
    from 
        orders
),

customer_agg as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(total_amount) as total_spent,
        avg(total_amount) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from 
        base
    group by 
        customer_id

)

select
    c.customer_id,
    c.total_orders,
    round(c.total_spent::numeric,2) as total_spent,
    round(c.avg_order_value::numeric,2) as avg_order_value,
    c.first_order_date,
    c.last_order_date,
    (current_date - c.last_order_date::date) as recency_days,
    case 
        when c.total_orders = 0 then 0
        else round((c.total_spent / c.total_orders)::numeric,2)
    end as lifetime_value
from 
    customer_agg c
