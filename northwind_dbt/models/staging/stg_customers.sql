select
    *
from {{ source('northwind', 'customers') }}