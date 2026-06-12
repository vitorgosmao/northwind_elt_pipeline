select
    *
from {{ source('northwind', 'suppliers') }}