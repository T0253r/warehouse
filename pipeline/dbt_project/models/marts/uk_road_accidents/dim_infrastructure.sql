with stg_collisions as (
    select * from {{ ref('stg_dft__collisions') }}
),

dim_infrastructure as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'first_road_class', 
            'first_road_number', 
            'second_road_class', 
            'second_road_number', 
            'road_type', 
            'speed_limit'
        ]) }} as infrastructure_key,
        first_road_class,
        first_road_number,
        second_road_class,
        second_road_number,
        road_type,
        speed_limit
    from stg_collisions
)

select * from dim_infrastructure
