with stg_collisions as (
    select * from {{ ref('stg_dft__collisions') }}
),

dim_date as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'collision_date', 
            'collision_year', 
            'day_of_week'
        ]) }} as date_key,
        collision_date,
        collision_year,
        day_of_week
    from stg_collisions
    where collision_date is not null
)

select * from dim_date
