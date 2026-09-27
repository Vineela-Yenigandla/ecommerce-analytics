{{ config(materialized='table') }}

-- Grain: one row per item line within an order.
-- Order-level totals deliberately excluded to prevent double-counting.

with items as (

    select * from {{ ref('int_order_items_enriched') }}

),

orders as (

    select
        order_id,
        order_status,
        purchased_at,
        purchased_at::date as order_date
    from {{ ref('stg_orders') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['i.order_id', 'i.order_item_number']) }} as order_item_key,
        i.order_id,
        i.order_item_number,
        i.product_id,
        i.seller_id,
        i.product_category,

        o.order_status,
        o.purchased_at,
        o.order_date,

        i.item_price,
        i.freight_value,
        i.item_price + i.freight_value  as item_total,
        i.shipping_limit_at

    from items i
    inner join orders o on i.order_id = o.order_id

)

select * from final
