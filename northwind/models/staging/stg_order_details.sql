{{ config(
    schema='silver',
    materialized='table'
) }}
    
select
    order_id,
    product_id,
    unit_price,
    quantity,
    discount,
    (unit_price * quantity * (1 - discount)) as total_sales
from {{ref('raw_order_details')}}