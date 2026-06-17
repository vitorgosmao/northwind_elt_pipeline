

with products as (
    select 
        *
    from 
        {{ ref('stg_products') }}
),

categories as (
    select
        category_id,
        category_name
    from 
        {{ ref('stg_categories') }}
),

suppliers as (
    select
        supplier_id,
        company_name as supplier_name,
        country as supplier_country
    from {{ ref('stg_suppliers') }}   
) 
select
    p.product_id,
    p.product_name,
    p.category_id,
    c.category_name,
    p.supplier_id,
    s.supplier_name,
    s.supplier_country,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    p.reorder_level,
    case
        when p.unit_price < 20 then 'Low'
        when p.unit_price < 50 then 'Medium'
        else 'High'
    end as price_category
from products p
    left join categories c
        on p.category_id = c.category_id
    left join suppliers s
        on p.supplier_id = s.supplier_id

