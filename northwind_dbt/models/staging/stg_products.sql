select
    *
from {{ source('northwind', 'products') }}