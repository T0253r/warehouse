with stg_collisions as (
    select * from {{ ref('stg_dft__collisions') }}
),

dim_conditions as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'light_conditions', 
            'weather_conditions', 
            'road_surface_conditions', 
            'special_conditions_at_site'
        ]) }} as condition_key,
        light_conditions,
        weather_conditions,
        road_surface_conditions,
        special_conditions_at_site
    from stg_collisions
)

select * from dim_conditions
