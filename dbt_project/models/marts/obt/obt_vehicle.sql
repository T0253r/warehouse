{{ config(materialized='view') }}

select
    f.* exclude (date_key, time_key, location_key, infrastructure_key, condition_key, vehicle_profile_key, dynamics_key),
    vp.* exclude (vehicle_profile_key),
    cd.* exclude (dynamics_key),
    d.date_day as collision_date,
    d.day_of_week,
    d.day_of_week_name,
    d.month_of_year,
    d.month_name,
    d.quarter_of_year,
    d.year_number,
    d.week_of_year,
    t.* exclude (time_key),
    l.* exclude (location_key),
    i.* exclude (infrastructure_key),
    c.* exclude (condition_key)
from {{ ref('fact_vehicle_involvement') }} f
left join {{ ref('dim_vehicle_profile') }} vp on f.vehicle_profile_key = vp.vehicle_profile_key
left join {{ ref('dim_collision_dynamics') }} cd on f.dynamics_key = cd.dynamics_key
left join {{ ref('dim_date') }} d on f.date_key = d.date_key
left join {{ ref('dim_time') }} t on f.time_key = t.time_key
left join {{ ref('dim_location') }} l on f.location_key = l.location_key
left join {{ ref('dim_infrastructures') }} i on f.infrastructure_key = i.infrastructure_key
left join {{ ref('dim_conditions') }} c on f.condition_key = c.condition_key
