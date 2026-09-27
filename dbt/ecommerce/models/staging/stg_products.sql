with source as (

    select * from {{ source('raw', 'raw_products') }}

),

renamed as (

    select
        product_id,
        {{ clean_text('product_category_name') }}   as product_category_pt,
        product_name_lenght::integer                as product_name_length,
        product_description_lenght::integer         as product_description_length,
        product_photos_qty::integer                 as product_photo_count,
        product_weight_g::integer                   as product_weight_grams,
        product_length_cm::integer                  as product_length_cm,
        product_height_cm::integer                  as product_height_cm,
        product_width_cm::integer                   as product_width_cm

    from source

)

select * from renamed
