{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        condition_key,
        light_conditions,
        weather_conditions,
        road_surface_conditions,
        special_conditions_at_site,
        carriageway_hazards
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
