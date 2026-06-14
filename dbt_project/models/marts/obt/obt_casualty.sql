{{ config(materialized='view') }}

select
    f.* exclude (date_key, time_key, location_key, infrastructure_key, condition_key, casualty_profile_key, vehicle_profile_key),
    cp.casualty_class,
    cp.casualty_type,
    cp.sex_of_casualty,
    cp.age_of_casualty,
    cp.age_band_of_casualty,
    cp.casualty_severity,
    cp.pedestrian_location,
    cp.pedestrian_movement,
    cp.car_passenger,
    cp.casualty_distance_banding,
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
from {{ ref('fact_casualty_involvement') }} f
left join {{ ref('dim_casualty_profile') }} cp on f.casualty_profile_key = cp.casualty_profile_key
left join {{ ref('dim_vehicle_profile') }} vp on f.vehicle_profile_key = vp.vehicle_profile_key
left join {{ ref('dim_date') }} d on f.date_key = d.date_key
left join {{ ref('dim_time') }} t on f.time_key = t.time_key
left join {{ ref('dim_location') }} l on f.location_key = l.location_key
left join {{ ref('dim_infrastructures') }} i on f.infrastructure_key = i.infrastructure_key
left join {{ ref('dim_conditions') }} c on f.condition_key = c.condition_key
