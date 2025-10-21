{{
    config(
        schema='gold',
        materialized='table'
    )
}}

-- 1. Importar as tabelas de staging (Silver)
with stg_orders as (
    select * from {{ ref('stg_orders') }}
),

stg_order_details as (
    select * from {{ ref('stg_order_details') }}
),

stg_employees as (
    select * from {{ ref('stg_employees') }}
),

-- 2. Pré-agregar os dados dos itens do pedido
-- Isso transforma os dados de "um item por linha" para "um pedido por linha"
order_details_agg as (
    select
        order_id,
        sum(total_sales) as total_sales,
        sum(quantity) as total_quantity
    from {{ ref('stg_order_details') }}
    group by 1
),

-- 3. Juntar tudo para criar o modelo final
final as (
    select
        -- Chaves
        so.order_id,
        so.customer_id,
        so.employee_id,

        -- Datas
        so.order_date,

        -- Métricas do Pedido
        sod.total_sales,
        sod.total_quantity,

        -- Detalhes de Envio
        so.ship_city,
        so.ship_country,

        -- Detalhes do Funcionário (enriquecimento)
        se.first_name as employee_first_name,
        se.last_name as employee_last_name,
        se.city as employee_city,
        se.country as employee_country

    from stg_orders as so

    left join order_details_agg as sod
        on so.order_id = sod.order_id
    
    left join stg_employees as se
        on so.employee_id = se.employee_id
)

select * from final