{{ config(materialized='view') }}

with collisions as (
    select * from {{ ref('stg_collisions') }}
),

casualties as (
    select * from {{ ref('stg_casualties') }}
),

fatalities as (
    select
        collision_index,
        count(*) as number_of_fatalities
    from casualties
    where casualty_severity = '1'
    group by collision_index
)

select
    -- Primary and business keys
    {{ dbt_utils.generate_surrogate_key(['c.collision_index']) }} as collision_key,
    c.collision_index,

    -- Foreign keys
    {{ dbt_utils.generate_surrogate_key(['c.date']) }} as date_key,
    {{ dbt_utils.generate_surrogate_key(['c.time']) }} as time_key,
    {{ dbt_utils.generate_surrogate_key(['c.longitude', 'c.latitude', 'c.police_force', 'c.local_authority_district']) }} as location_key,
    {{ dbt_utils.generate_surrogate_key(['c.road_type', 'c.speed_limit', 'c.junction_detail', 'c.junction_control']) }} as infrastructure_key,
    {{ dbt_utils.generate_surrogate_key(['c.light_conditions', 'c.weather_conditions', 'c.road_surface_conditions', 'c.special_conditions_at_site', 'c.carriageway_hazards']) }} as condition_key,

    -- Measures
    cast(c.number_of_vehicles as integer) as number_of_vehicles,
    cast(c.number_of_casualties as integer) as number_of_casualties,
    coalesce(f.number_of_fatalities, 0) as number_of_fatalities,

    -- Dimensional attributes for the OBTs and Dimension models
    cast(strptime(c.date, '%d/%m/%Y') as date) as collision_date,
    cast(c.time as time) as collision_time,
    cast(split_part(c.time, ':', 1) as integer) as collision_hour,
    case when cast(split_part(c.time, ':', 1) as integer) in (7,8,9,16,17,18) then true else false end as is_rush_hour,
    case
        when cast(split_part(c.time, ':', 1) as integer) between 6 and 11 then 'Morning'
        when cast(split_part(c.time, ':', 1) as integer) between 12 and 16 then 'Afternoon'
        when cast(split_part(c.time, ':', 1) as integer) between 17 and 21 then 'Evening'
        else 'Night'
    end as time_of_day,
    cast(c.longitude as float) as longitude,
    cast(c.latitude as float) as latitude,
    c.police_force,
    c.local_authority_district,
    c.road_type,
    cast(c.speed_limit as integer) as speed_limit,
    c.junction_detail,
    c.junction_control,
    c.light_conditions,
    c.weather_conditions,
    c.road_surface_conditions,
    c.special_conditions_at_site,
    coalesce(c.carriageway_hazards, c.carriageway_hazards_historic) as carriageway_hazards

from collisions c
left join fatalities f on c.collision_index = f.collision_index
