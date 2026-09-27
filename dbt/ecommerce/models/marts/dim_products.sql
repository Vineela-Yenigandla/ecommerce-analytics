{{ config(materialized='table') }}

-- Grain: one row per product.

with products as (

    select * from {{ ref('stg_products') }}

),

translation as (

    select * from {{ ref('stg_category_translation') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
        p.product_id,
        coalesce(t.product_category_en, 'Unknown')  as product_category,
        p.product_category_pt,
        p.product_weight_grams,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,
        (p.product_length_cm * p.product_height_cm * p.product_width_cm) as product_volume_cm3,
        p.product_photo_count,
        p.product_name_length,
        p.product_description_length

    from products p
    left join translation t on p.product_category_pt = t.product_category_pt

)

select * from final
