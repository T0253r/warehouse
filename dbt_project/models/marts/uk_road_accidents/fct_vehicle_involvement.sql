with stg_vehicles as (

    select * from {{ ref('stg_dft__vehicles') }}

),

stg_collisions as (

    select * from {{ ref('stg_dft__collisions') }}

),

fact_vehicle_involvement as (

    select
        -- Primary Key
        v.vehicle_key as vehicle_involvement_key,

        -- Natural Keys
        v.collision_index,
        v.vehicle_reference,
        
        -- Foreign Key bridging up to the Level 1 Fact Collision
        v.collision_key,

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

        -- Foreign Keys to Vehicle-specific Profile Dimensions
        v.vehicle_key as vehicle_profile_key,

        {{ dbt_utils.generate_surrogate_key([
            'v.junction_location'
        ]) }} as motion_key,

        {{ dbt_utils.generate_surrogate_key([
            'v.first_point_of_impact'
        ]) }} as dynamics_key

    from stg_vehicles v
    left join stg_collisions col on v.collision_index = col.collision_index

)

select * from fact_vehicle_involvement