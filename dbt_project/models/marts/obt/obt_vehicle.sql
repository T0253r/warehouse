{{ config(materialized='view') }}

select
    f.* exclude (date_key, time_key, location_key, infrastructure_key, condition_key, vehicle_profile_key, dynamics_key),
    vp.vehicle_type,
    vp.junction_location,
    vp.vehicle_left_hand_drive,
    vp.sex_of_driver,
    vp.age_of_driver,
    vp.age_band_of_driver,
    vp.engine_capacity_cc,
    vp.propulsion_code,
    vp.age_of_vehicle,
    vp.driver_distance_banding,
    vp.engine_capacity_banding,
    vp.age_band_of_vehicle,
    cd.skidding_and_overturning,
    cd.hit_object_in_carriageway,
    cd.vehicle_leaving_carriageway,
    cd.hit_object_off_carriageway,
    cd.first_point_of_impact,
    d.date_day as collision_date,
    d.day_of_week_name,
    d.month_name,
    t.collision_time,
    t.collision_hour,
    t.is_rush_hour,
    t.time_of_day,
    l.longitude,
    l.latitude,
    l.police_force,
    l.local_authority_district,
    i.road_type,
    i.speed_limit,
    i.junction_detail,
    i.junction_control,
    c.light_conditions,
    c.weather_conditions,
    c.road_surface_conditions,
    c.special_conditions_at_site,
    c.carriageway_hazards
from {{ ref('fact_vehicle_involvement') }} f
left join {{ ref('dim_vehicle_profile') }} vp on f.vehicle_profile_key = vp.vehicle_profile_key
left join {{ ref('dim_collision_dynamics') }} cd on f.dynamics_key = cd.dynamics_key
left join {{ ref('dim_date') }} d on f.date_key = d.date_key
left join {{ ref('dim_time') }} t on f.time_key = t.time_key
left join {{ ref('dim_location') }} l on f.location_key = l.location_key
left join {{ ref('dim_infrastructures') }} i on f.infrastructure_key = i.infrastructure_key
left join {{ ref('dim_conditions') }} c on f.condition_key = c.condition_key
