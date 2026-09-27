-- Order items with the English category name resolved.
-- Ephemeral: used by fct_order_items only, not queried directly.

with items as (

    select * from {{ ref('stg_order_items') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

translation as (

    select * from {{ ref('stg_category_translation') }}

),

final as (

    select
        i.order_id,
        i.order_item_number,
        i.product_id,
        i.seller_id,
        i.shipping_limit_at,
        i.item_price,
        i.freight_value,
        coalesce(t.product_category_en, 'Unknown') as product_category

    from items i
    left join products p    on i.product_id = p.product_id
    left join translation t on p.product_category_pt = t.product_category_pt

)

select * from final
