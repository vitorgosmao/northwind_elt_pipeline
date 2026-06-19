with order_items as (
    select 
        *
    from 
        {{ ref('fct_order_items') }}
),

products as (
    select 
        *
    from 
        {{ ref('stg_products') }}
),

categories as (
    select 
        *
    from 
        {{ ref('stg_categories') }}
),

base as (
    select
        oi.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        oi.quantity,
        oi.unit_price,
        oi.sale_amount
    from 
        order_items oi
        left join products p
            on oi.product_id = p.product_id
        left join categories c
            on p.category_id = c.category_id
),

product_agg as (
    select
        product_id,
        product_name,
        category_name,
        sum(quantity) as total_quantity_sold,
        sum(sale_amount) as total_revenue,
        avg(unit_price) as avg_unit_price,
        count(distinct product_id) as product_orders
    from 
        base
    group by 1,2,3
)

select
    product_id,
    product_name,
    category_name, 
    total_quantity_sold,
    round(total_revenue::numeric, 2) as total_revenue,
    round(avg_unit_price::numeric, 2) as avg_unit_price,
    product_orders,
    -- ranking de produtos por receita
    rank() over (
        order by total_revenue desc
    ) as revenue_rank
from product_agg
