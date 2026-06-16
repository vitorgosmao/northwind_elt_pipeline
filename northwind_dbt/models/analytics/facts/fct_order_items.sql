-- tabelas que serao utilizadas: 

-- stg_orders
-- stg_order_details
-- stg_products
-- stg_categories

with order_items as ( 
    select 
        order_id, 
        product_id, 
        unit_price,
        quantity,
        discount
    from 
        {{ ref('stg_order_details') }}
), 

orders as (
    select 
        order_id, 
        customer_id, 
        employee_id, 
        order_date, 
        ship_country
    from 
        {{ ref('stg_orders') }}
), 

products as (
    select
        product_id, 
        product_name,
        category_id,
        supplier_id
    from 
        {{ ref('stg_products') }}
), 

categories as (
    select
        category_id,
        category_name
    from 
        {{ ref('stg_categories') }}

)

select
    {{ 
        dbt_utils.generate_surrogate_key(
            ['oi.order_id', 'oi.product_id']
        )
    }} as order_item_id, 
    oi.order_id, 
    oi.product_id, 
    o.customer_id, 
    o.employee_id, 
    o.order_date,
    o.ship_country, 
    p.product_name,
    c.category_name, 
    c.category_id, 
    oi.unit_price, 
    oi.quantity, 
    oi.discount, 
    (oi.unit_price * oi.quantity * (1 - discount)) as sale_amount
from 
    order_items oi 
    inner join orders o
        on oi.order_id = o.order_id    
    left join products p
        on oi.product_id = p.product_id
    left join categories c
        on p.category_id = c.category_id
