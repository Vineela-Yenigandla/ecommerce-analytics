with source as (

    select * from {{ source('raw', 'raw_order_reviews') }}

),

renamed as (

    select
        review_id,
        order_id,
        review_score::integer                       as review_score,
        {{ clean_text('review_comment_title') }}    as review_title,
        {{ clean_text('review_comment_message') }}  as review_message,
        review_creation_date::timestamp             as review_created_at,
        review_answer_timestamp::timestamp          as review_answered_at

    from source

)

select * from renamed
