{{ config(
    schema='silver',
    materialized='view'
) }}

select
    customer_id, 
    company_name,
    contact_name, 
    contact_title,
    address,
    city,country 
from {{ref('raw_customers')}}