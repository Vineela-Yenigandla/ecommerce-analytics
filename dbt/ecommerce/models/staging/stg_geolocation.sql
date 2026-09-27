with source as (

    select * from {{ source('raw', 'raw_geolocation') }}

),

renamed as (

    select
        geolocation_zip_code_prefix::varchar    as zip_prefix,
        geolocation_lat::double                 as latitude,
        geolocation_lng::double                 as longitude,
        {{ clean_title('geolocation_city') }}   as city,
        upper(trim(geolocation_state))          as state

    from source

),

deduplicated as (

    select
        zip_prefix,
        avg(latitude)   as latitude,
        avg(longitude)  as longitude,
        min(city)       as city,
        min(state)      as state

    from renamed
    group by zip_prefix

)

select * from deduplicated
