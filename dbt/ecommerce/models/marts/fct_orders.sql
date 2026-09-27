{{ config(materialized='table') }}

-- Grain: one row per order.
-- All measures are valid at order level. Item-level measures live in fct_order_items.

with orders as (

    select * from {{ ref('stg_orders') }}

),

totals as (

    select * from {{ ref('int_order_totals') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

final as (

    select
        -- keys
        o.order_id,
        {{ dbt_utils.generate_surrogate_key(['o.order_id']) }}  as order_key,
        c.customer_unique_id,
        o.customer_id                                           as customer_order_id,

        -- status
        o.order_status,
        o.order_status = 'delivered'                            as is_delivered,
        o.order_status = 'canceled'                             as is_canceled,

        -- dates
        o.purchased_at,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,
        o.purchased_at::date                                    as order_date,

        -- measures
        coalesce(t.item_count, 0)                               as item_count,
        coalesce(t.items_total, 0)                              as items_total,
        coalesce(t.freight_total, 0)                            as freight_total,
        coalesce(t.items_total, 0) + coalesce(t.freight_total, 0) as order_total,
        coalesce(t.payment_total, 0)                            as payment_total,
        t.max_installments,
        t.distinct_product_count,
        t.distinct_seller_count,
        t.review_score,

        -- derived timings
        date_diff('day', o.purchased_at, o.delivered_at)        as days_to_delivery,
        date_diff('day', o.estimated_delivery_at, o.delivered_at) as delivery_delay_days,
        case
            when o.delivered_at is null then null
            when o.delivered_at > o.estimated_delivery_at then true
            else false
        end                                                     as is_delivered_late

    from orders o
    left join totals t    on o.order_id = t.order_id
    left join customers c on o.customer_id = c.customer_id

)

select * from final
