{% snapshot customers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_unique_id',
      strategy='check',
      check_cols=['customer_city', 'customer_state', 'customer_zip_prefix'],
      invalidate_hard_deletes=True
    )
}}

-- Keyed on customer_unique_id, the real person identifier.
-- Source has one row per customer-order pairing, so we take the most recent
-- attributes per person to avoid duplicate keys in the snapshot.

with ranked as (

    select
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        c.customer_zip_prefix,
        row_number() over (
            partition by c.customer_unique_id
            order by o.purchased_at desc
        ) as rn

    from {{ ref('stg_customers') }} c
    left join {{ ref('stg_orders') }} o on c.customer_id = o.customer_id

)

select
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_prefix

from ranked
where rn = 1

{% endsnapshot %}
