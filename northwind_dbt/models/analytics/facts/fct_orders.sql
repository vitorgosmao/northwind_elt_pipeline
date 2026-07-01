-- tabelas que serao utilizadas: 

-- stg_orders
-- fct_order_items

with orders as (
    select 
        order_id, 
        customer_id, 
        employee_id, 
        order_date,
        required_date, 
        shipped_date,
        ship_country
    from 
        {{ ref('stg_orders') }}
),

order_metrics as (
    select
        order_id, 
        count(product_id) as total_items, 
        sum(quantity) as total_quantity,
        sum(sale_amount) as total_amount, 
        avg(sale_amount) as average_item_value
    from 
        {{ ref('fct_order_items') }}
    group by 
        order_id
)

select
    o.order_id,
    o.customer_id,
    o.employee_id,
    o.order_date,
    o.ship_country,
    o.required_date,
    o.shipped_date,
    -- metricas
    coalesce(om.total_items,0) as total_items,
    coalesce(om.total_quantity,0) as total_quantity,
    coalesce(om.total_amount,0) as total_amount,
    coalesce(om.average_item_value,0) as average_item_value,
    -- indicadores
    case
        when o.shipped_date is null then 'pending'
        when o.shipped_date <= o.required_date then 'on time' else 'late'
    end as shipping_status
from orders o
    left join order_metrics om
        on o.order_id = om.order_id
