select 
    * 
from {{ source('northwind', 'orders') }}
