select
    *
from {{ source('northwind', 'shippers') }}