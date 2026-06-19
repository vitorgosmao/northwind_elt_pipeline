with order_items as (
    select 
        *
    from 
        {{ ref('fct_order_items') }}

),

orders as (
    select 
        *
    from 
        {{ ref('stg_orders') }}
),

base as (
    select
        oi.order_id,
        o.order_date,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.sale_amount
    from 
        order_items oi
    left join orders o
        on oi.order_id = o.order_id
)

select
    date_trunc('month', order_date)::date as sales_month,
    count(distinct order_id) as total_orders,
    count(*) as total_items_sold,
    sum(quantity) as total_quantity,
    round(sum(sale_amount)::numeric, 2) as total_revenue,
    round(avg(unit_price)::numeric, 2) as avg_unit_price
from 
    base
group by 1

