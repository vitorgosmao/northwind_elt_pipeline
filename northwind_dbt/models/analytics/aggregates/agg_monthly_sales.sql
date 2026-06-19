select
    date_trunc('month', order_date) as sales_month,
    count(distinct order_id) as total_orders,
    count(*) as total_items,
    sum(quantity) as total_quantity,
    sum(sale_amount) as total_revenue
from 
    {{ ref('fct_order_items') }}
group by 1