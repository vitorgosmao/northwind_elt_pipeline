select
    *
from {{ source('northwind', 'employee_territories') }}