{{ config(
    schema='silver',
    materialized='table'
) }}

select 
    category_id,
    category_name,
    description
from {{ref('raw_categories')}}