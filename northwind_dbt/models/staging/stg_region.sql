select
    *
from {{ source('northwind', 'region') }}