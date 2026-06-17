select
    category_id,
    category_name,
    description
from 
    {{ ref('stg_categories') }}