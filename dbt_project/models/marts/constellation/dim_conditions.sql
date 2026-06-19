{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        condition_key,
        {{ map_id('collision', 'light_conditions') }} as light_conditions,
        {{ map_id('collision', 'weather_conditions') }} as weather_conditions,
        {{ map_id('collision', 'road_surface_conditions') }} as road_surface_conditions,
        {{ map_id('collision', 'special_conditions_at_site') }} as special_conditions_at_site,
        {{ map_id('collision', 'carriageway_hazards') }} as carriageway_hazards
    from {{ ref('int_collisions') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.condition_key = target_table.condition_key
    )
{% endif %}
