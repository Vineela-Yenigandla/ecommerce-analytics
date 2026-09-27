with source as (

    select * from {{ source('raw', 'raw_order_payments') }}

),

renamed as (

    select
        order_id,
        payment_sequential::integer         as payment_sequence,
        lower(trim(payment_type))           as payment_type,
        payment_installments::integer       as payment_installments,
        payment_value::decimal(10,2)        as payment_value

    from source

)

select * from renamed
