-- Every order in the source must appear in fct_orders.
-- Catches rows silently dropped by a join or filter.

with source_count as (
    select count(*) as n from {{ source('raw', 'raw_orders') }}
),

mart_count as (
    select count(*) as n from {{ ref('fct_orders') }}
)

select
    s.n as source_orders,
    m.n as mart_orders,
    s.n - m.n as difference
from source_count s
cross join mart_count m
where s.n != m.n
