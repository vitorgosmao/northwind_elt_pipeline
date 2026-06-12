select
    *
from {{ source('northwind', 'categories') }}