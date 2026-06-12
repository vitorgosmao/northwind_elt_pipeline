select
    *
from {{ source('northwind', 'territories') }}