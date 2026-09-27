with source as (

    select * from {{ source('raw', 'raw_sellers') }}

),

renamed as (

    select
        seller_id,
        seller_zip_code_prefix::varchar     as seller_zip_prefix,
        {{ clean_title('seller_city') }}    as seller_city,
        upper(trim(seller_state))           as seller_state

    from source

)

select * from renamed
