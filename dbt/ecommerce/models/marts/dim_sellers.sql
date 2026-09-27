{{ config(materialized='table') }}

-- Grain: one row per seller.

with sellers as (

    select * from {{ ref('stg_sellers') }}

),

seller_stats as (

    select
        seller_id,
        count(distinct order_id)    as total_orders,
        count(*)                    as total_items_sold,
        sum(item_price)             as lifetime_revenue

    from {{ ref('stg_order_items') }}
    group by seller_id

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['s.seller_id']) }} as seller_key,
        s.seller_id,
        s.seller_city,
        s.seller_state,
        s.seller_zip_prefix,
        coalesce(ss.total_orders, 0)        as total_orders,
        coalesce(ss.total_items_sold, 0)    as total_items_sold,
        coalesce(ss.lifetime_revenue, 0)    as lifetime_revenue

    from sellers s
    left join seller_stats ss on s.seller_id = ss.seller_id

)

select * from final
