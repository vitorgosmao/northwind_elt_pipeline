with orders as (
    select 
        *
    from 
        {{ ref('fct_orders') }}
),

customers as (
    select 
        *
    from 
        {{ ref('stg_customers') }}
),

base as (
    select
        o.order_id,
        o.customer_id,
        c.country,
        c.city,
        o.total_amount,
        o.order_date
    from 
        orders o
        left join customers c
            on o.customer_id = c.customer_id

),

region_agg as (
    select
        country,
        city,
        count(distinct order_id) as total_orders,
        sum(total_amount) as total_revenue,
        avg(total_amount) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from 
        base
    group by 1,2
)

select
    country,
    city,
    total_orders,
    round(total_revenue::numeric, 2) as total_revenue,
    round(avg_order_value::numeric, 2) as avg_order_value,
    first_order_date,
    last_order_date
from region_agg