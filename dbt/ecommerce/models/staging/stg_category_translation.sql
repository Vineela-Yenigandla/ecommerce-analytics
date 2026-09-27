with source as (

    select * from {{ source('raw', 'raw_category_translation') }}

),

renamed as (

    select
        {{ clean_text('product_category_name') }}           as product_category_pt,
        {{ clean_title('product_category_name_english') }}  as product_category_en

    from source

)

select * from renamed
