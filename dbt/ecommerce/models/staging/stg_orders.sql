with source as (

    select * from {{ source('raw', 'raw_orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        lower(trim(order_status))                        as order_status,
        order_purchase_timestamp::timestamp              as purchased_at,
        order_approved_at::timestamp                     as approved_at,
        order_delivered_carrier_date::timestamp          as shipped_at,
        order_delivered_customer_date::timestamp         as delivered_at,
        order_estimated_delivery_date::timestamp         as estimated_delivery_at

    from source

)

select * from renamed
