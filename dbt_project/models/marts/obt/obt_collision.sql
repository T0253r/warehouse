{{ config(materialized='view') }}

select
    f.* exclude (date_key, time_key, location_key, infrastructure_key, condition_key),
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
from {{ ref('fact_collision') }} f
left join {{ ref('dim_date') }} d on f.date_key = d.date_key
left join {{ ref('dim_time') }} t on f.time_key = t.time_key
left join {{ ref('dim_location') }} l on f.location_key = l.location_key
left join {{ ref('dim_infrastructures') }} i on f.infrastructure_key = i.infrastructure_key
left join {{ ref('dim_conditions') }} c on f.condition_key = c.condition_key
