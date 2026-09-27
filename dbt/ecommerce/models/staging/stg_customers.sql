with source as (

    select * from {{ source('raw', 'raw_customers') }}

),

renamed as (

    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix::varchar     as customer_zip_prefix,
        {{ clean_title('customer_city') }}    as customer_city,
        upper(trim(customer_state))           as customer_state

    from source

)

select * from renamed
