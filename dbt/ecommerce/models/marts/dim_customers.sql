{{ config(materialized='table') }}

-- Grain: one row per customer VERSION (SCD Type 2).
-- A customer with a changed city appears more than once.
-- Filter on is_current for the present-day view, or join on the validity
-- window for point-in-time accuracy.

with snapshotted as (

    select * from {{ ref('customers_snapshot') }}

),

order_stats as (

    select
        c.customer_unique_id,
        count(distinct o.order_id)                  as lifetime_orders,
        min(o.purchased_at)::date                   as first_order_date,
        max(o.purchased_at)::date                   as last_order_date

    from {{ ref('stg_customers') }} c
    inner join {{ ref('stg_orders') }} o on c.customer_id = o.customer_id
    group by c.customer_unique_id

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['s.customer_unique_id', 's.dbt_valid_from']) }} as customer_key,
        s.customer_unique_id,

        s.customer_city,
        s.customer_state,
        s.customer_zip_prefix,

        s.dbt_valid_from                            as valid_from,
        s.dbt_valid_to                              as valid_to,
        s.dbt_valid_to is null                      as is_current,

        os.lifetime_orders,
        os.first_order_date,
        os.last_order_date

    from snapshotted s
    left join order_stats os on s.customer_unique_id = os.customer_unique_id

)

select * from final
