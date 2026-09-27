{{ config(materialized='table') }}

-- Grain: one row per calendar date.
-- Range covers the Olist dataset with a buffer either side.

with spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2019-12-31' as date)"
    ) }}

),

final as (

    select
        date_day::date                                  as date_key,
        date_day::date                                  as full_date,
        extract(year    from date_day)::integer         as year,
        extract(quarter from date_day)::integer         as quarter,
        extract(month   from date_day)::integer         as month_number,
        strftime(date_day, '%B')                        as month_name,
        strftime(date_day, '%b')                        as month_short,
        extract(week    from date_day)::integer         as week_of_year,
        extract(day     from date_day)::integer         as day_of_month,
        extract(dayofweek from date_day)::integer       as day_of_week,
        strftime(date_day, '%A')                        as day_name,
        extract(dayofweek from date_day) in (0, 6)      as is_weekend,
        date_trunc('month', date_day)::date             as month_start_date,
        (date_trunc('month', date_day) + interval 1 month - interval 1 day)::date as month_end_date,
        strftime(date_day, '%Y-%m')                     as year_month

    from spine

)

select * from final
