with stg_casualties as (

    select * from {{ ref('stg_dft__casualties') }}

),

stg_collisions as (

    select * from {{ ref('stg_dft__collisions') }}

),

fact_casualty_involvement as (

    select
        -- Primary Key
        c.casualty_key as casualty_involvement_key,

        -- Natural Keys (Kept for traceability/debugging)
        c.collision_index,
        c.vehicle_reference,
        c.casualty_reference,

        -- Foreign Keys bridging up to the Level 1 Fact tables
        c.collision_key,

        -- Foreign Keys to Core Context Conformed Dimensions
        {{ dbt_utils.generate_surrogate_key([
            'col.collision_date', 
            'col.collision_year', 
            'col.day_of_week'
        ]) }} as date_key,

        {{ dbt_utils.generate_surrogate_key([
            'col.collision_time'
        ]) }} as time_key,

        {{ dbt_utils.generate_surrogate_key([
            'col.longitude', 
            'col.latitude', 
            'col.police_force', 
            'col.local_authority_district'
        ]) }} as location_key,

        {{ dbt_utils.generate_surrogate_key([
            'col.first_road_class', 
            'col.first_road_number', 
            'col.second_road_class', 
            'col.second_road_number', 
            'col.road_type', 
            'col.speed_limit'
        ]) }} as infrastructure_key,

        {{ dbt_utils.generate_surrogate_key([
            'col.light_conditions', 
            'col.weather_conditions', 
            'col.road_surface_conditions', 
            'col.special_conditions_at_site'
        ]) }} as condition_key,

        -- Foreign Keys to Specific Dimensions
        c.casualty_key as casualty_profile_key,
        c.vehicle_key as vehicle_profile_key

    from stg_casualties c
    left join stg_collisions col on c.collision_index = col.collision_index

)

select * from fact_casualty_involvement