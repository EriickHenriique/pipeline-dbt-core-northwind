{{ config(
    schema='silver',
    materialized='view'
) }}

select
        order_id,
        customer_id,
        employee_id,
        ship_via as shipper_id,
        order_date,
        required_date,
        shipped_date,
        ship_name,
        ship_city,
        ship_country
from {{ref('raw_orders')}}