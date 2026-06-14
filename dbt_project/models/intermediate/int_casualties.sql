{{ config(materialized='view') }}

with casualties as (
    select * from {{ ref('stg_casualties') }}
),

collisions as (
    select * from {{ ref('int_collisions') }}
),

vehicles as (
    select * from {{ ref('int_vehicles') }}
),

casualties_with_derived as (
    select
        c.*,
        coalesce(nullif(c.enhanced_casualty_severity, '-1'), c.casualty_severity) as casualty_severity
    from casualties c
)

select
    -- Primary and business keys
    {{ dbt_utils.generate_surrogate_key(['cas.collision_index', 'cas.vehicle_reference', 'cas.casualty_reference']) }} as casualty_involvement_key,
    cas.collision_index,
    
    -- Foreign keys from collisions
    c.date_key,
    c.time_key,
    c.location_key,
    c.infrastructure_key,
    c.condition_key,

    -- Foreign key from vehicles
    v.vehicle_profile_key,

    -- Dimensional surrogate key for casualty profile
    {{ dbt_utils.generate_surrogate_key([
        'cas.casualty_class', 'cas.casualty_type', 'cas.sex_of_casualty',
        'cas.age_of_casualty', 'cas.age_band_of_casualty',
        'cas.casualty_severity', 'cas.pedestrian_location', 'cas.pedestrian_movement',
        'cas.car_passenger', 'cas.casualty_distance_banding'
    ]) }} as casualty_profile_key,

    -- Casualty profile attributes
    cas.casualty_class,
    cas.casualty_type,
    cas.sex_of_casualty,
    cast(cas.age_of_casualty as integer) as age_of_casualty,
    cas.age_band_of_casualty,
    cas.casualty_severity,
    cas.pedestrian_location,
    cas.pedestrian_movement,
    cas.car_passenger,
    cas.casualty_distance_banding

from casualties_with_derived cas
left join collisions c on cas.collision_index = c.collision_index
left join vehicles v on cas.collision_index = v.collision_index and cas.vehicle_reference = cast(v.vehicle_reference as varchar)
