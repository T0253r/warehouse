{{ config(materialized='view') }}

with vehicles as (
    select * from {{ ref('stg_vehicles') }}
),

collisions as (
    select * from {{ ref('int_collisions') }}
),

vehicles_with_derived as (
    select
        v.*,
        case
            when cast(v.engine_capacity_cc as integer) <= 1000 then 'Up to 1000cc'
            when cast(v.engine_capacity_cc as integer) <= 2000 then '1001 to 2000cc'
            when cast(v.engine_capacity_cc as integer) <= 3000 then '2001 to 3000cc'
            when cast(v.engine_capacity_cc as integer) > 3000 then 'Over 3000cc'
            else 'Unknown'
        end as engine_capacity_banding,
        case
            when cast(v.age_of_vehicle as integer) <= 5 then '0-5 years'
            when cast(v.age_of_vehicle as integer) <= 10 then '6-10 years'
            when cast(v.age_of_vehicle as integer) <= 15 then '11-15 years'
            when cast(v.age_of_vehicle as integer) > 15 then '16+ years'
            else 'Unknown'
        end as age_band_of_vehicle
    from vehicles v
)

select
    -- Primary and business keys
    {{ dbt_utils.generate_surrogate_key(['v.collision_index', 'v.vehicle_reference']) }} as vehicle_involvement_key,
    v.collision_index,
    v.vehicle_reference,
    
    -- Foreign keys from collisions
    c.date_key,
    c.time_key,
    c.location_key,
    c.infrastructure_key,
    c.condition_key,

    -- Dimensional surrogate keys
    {{ dbt_utils.generate_surrogate_key([
        'v.vehicle_type', 'v.junction_location', 'v.vehicle_left_hand_drive',
        'v.sex_of_driver', 'v.age_of_driver', 'v.age_band_of_driver',
        'v.engine_capacity_cc', 'v.propulsion_code', 'v.age_of_vehicle',
        'v.driver_distance_banding', 'v.engine_capacity_banding', 'v.age_band_of_vehicle'
    ]) }} as vehicle_profile_key,

    {{ dbt_utils.generate_surrogate_key([
        'v.skidding_and_overturning', 'v.hit_object_in_carriageway',
        'v.vehicle_leaving_carriageway', 'v.hit_object_off_carriageway',
        'v.first_point_of_impact'
    ]) }} as dynamics_key,

    -- Vehicle profile attributes
    v.vehicle_type,
    v.junction_location,
    v.vehicle_left_hand_drive,
    v.sex_of_driver,
    cast(v.age_of_driver as integer) as age_of_driver,
    v.age_band_of_driver,
    cast(v.engine_capacity_cc as integer) as engine_capacity_cc,
    v.propulsion_code,
    cast(v.age_of_vehicle as integer) as age_of_vehicle,
    v.driver_distance_banding,
    v.engine_capacity_banding,
    v.age_band_of_vehicle,

    -- Collision dynamics attributes
    v.skidding_and_overturning,
    v.hit_object_in_carriageway,
    v.vehicle_leaving_carriageway,
    v.hit_object_off_carriageway,
    v.first_point_of_impact

from vehicles_with_derived v
left join collisions c on v.collision_index = c.collision_index
