-- No order can be purchased in the future.

select order_id, purchased_at
from {{ ref('fct_orders') }}
where purchased_at > current_date
