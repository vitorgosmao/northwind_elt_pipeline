select
    *
from {{ source('northwind', 'employees') }}