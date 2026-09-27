-- Order-level rollups from item and payment grain.
-- Aggregating here keeps fct_orders at one row per order.

with items as (

    select
        order_id,
        count(*)                as item_count,
        sum(item_price)         as items_total,
        sum(freight_value)      as freight_total,
        count(distinct product_id) as distinct_product_count,
        count(distinct seller_id)  as distinct_seller_count

    from {{ ref('stg_order_items') }}
    group by order_id

),

payments as (

    select
        order_id,
        count(*)                    as payment_count,
        sum(payment_value)          as payment_total,
        max(payment_installments)   as max_installments

    from {{ ref('stg_order_payments') }}
    group by order_id

),

reviews as (

    select
        order_id,
        avg(review_score)::decimal(3,2)  as review_score,
        count(*)                         as review_count

    from {{ ref('stg_order_reviews') }}
    group by order_id

)

select
    coalesce(i.order_id, p.order_id, r.order_id) as order_id,
    i.item_count,
    i.items_total,
    i.freight_total,
    i.distinct_product_count,
    i.distinct_seller_count,
    p.payment_count,
    p.payment_total,
    p.max_installments,
    r.review_score,
    r.review_count

from items i
full outer join payments p on i.order_id = p.order_id
full outer join reviews  r on coalesce(i.order_id, p.order_id) = r.order_id
