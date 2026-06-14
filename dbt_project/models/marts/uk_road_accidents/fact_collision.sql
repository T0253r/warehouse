with stg_collisions as (

    select * from {{ ref('stg_dft__collisions') }}

),

fact_collision as (

    select
        -- Primary Key
        collision_key,

        -- Natural Key
        collision_index,

        -- Foreign Keys 
        {{ dbt_utils.generate_surrogate_key([
            'collision_date', 
            'collision_year', 
            'day_of_week'
        ]) }} as date_key,

        {{ dbt_utils.generate_surrogate_key([
            'collision_time'
        ]) }} as time_key,

        {{ dbt_utils.generate_surrogate_key([
            'longitude', 
            'latitude', 
            'police_force', 
            'local_authority_district'
        ]) }} as location_key,

        {{ dbt_utils.generate_surrogate_key([
            'first_road_class', 
            'first_road_number', 
            'second_road_class', 
            'second_road_number', 
            'road_type', 
            'speed_limit'
        ]) }} as infrastructure_key,

        {{ dbt_utils.generate_surrogate_key([
            'light_conditions', 
            'weather_conditions', 
            'road_surface_conditions', 
            'special_conditions_at_site'
        ]) }} as condition_key,

        -- Measures
        number_of_vehicles,
        number_of_casualties

    from stg_collisions

)

select * from fact_collision