{{ config(
    schema='silver',
    materialized='view'
) }}

select 
    category_id,
    category_name,
    description
from {{ref('raw_categories')}}