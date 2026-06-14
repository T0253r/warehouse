{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select
        collision_key,
        collision_index,
        date_key,
        time_key,
        location_key,
        infrastructure_key,
        condition_key,
        number_of_vehicles,
        number_of_casualties,
        number_of_fatalities
    from {{ ref('int_collisions') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.collision_key = target_table.collision_key
    )
{% endif %}
