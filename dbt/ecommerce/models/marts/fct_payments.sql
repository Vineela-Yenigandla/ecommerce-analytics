{{ config(materialized='table') }}

-- Grain: one row per payment transaction.
-- An order may be paid with several methods or in sequence.

with payments as (

    select * from {{ ref('stg_order_payments') }}

),

orders as (

    select
        order_id,
        order_status,
        purchased_at::date as order_date
    from {{ ref('stg_orders') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['p.order_id', 'p.payment_sequence']) }} as payment_key,
        p.order_id,
        p.payment_sequence,
        p.payment_type,
        p.payment_installments,
        p.payment_value,
        p.payment_installments > 1  as is_installment_payment,

        o.order_status,
        o.order_date

    from payments p
    inner join orders o on p.order_id = o.order_id

)

select * from final
