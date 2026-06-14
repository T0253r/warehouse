with stg_collisions as (
    select * from {{ ref('stg_dft__collisions') }}
),

dim_time as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'collision_time'
        ]) }} as time_key,
        collision_time
    from stg_collisions
    where collision_time is not null
)

select * from dim_time
