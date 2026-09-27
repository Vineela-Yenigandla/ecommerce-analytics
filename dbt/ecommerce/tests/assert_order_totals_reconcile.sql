-- items_total on fct_orders must equal the sum of item prices in fct_order_items.
-- Catches fan-out or double-counting between the two grains.

with order_level as (
    select order_id, items_total
    from {{ ref('fct_orders') }}
),

item_level as (
    select order_id, sum(item_price) as items_total
    from {{ ref('fct_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.items_total       as order_grain_total,
    i.items_total       as item_grain_total,
    abs(o.items_total - i.items_total) as difference

from order_level o
inner join item_level i on o.order_id = i.order_id
where abs(o.items_total - i.items_total) > 0.01
