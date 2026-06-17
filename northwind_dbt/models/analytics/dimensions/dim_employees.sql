select
    employee_id,
    first_name,
    last_name,
    concat(first_name,' ',last_name) as employee_name,
    title,
    birth_date,
    hire_date,
    city,
    country
from 
    {{ ref('stg_employees') }}