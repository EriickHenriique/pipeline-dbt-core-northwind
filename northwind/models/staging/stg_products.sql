{{ config(
    schema='silver',
    materialized='table'
) }}


select
        product_id,
        supplier_id,
        category_id,
        product_name,
        unit_price,
        units_in_stock,
        units_on_order,
        reorder_level,
        discontinued
from {{ref('raw_products')}}