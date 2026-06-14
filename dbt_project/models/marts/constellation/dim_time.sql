{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        time_key,
        collision_time,
        collision_hour,
        is_rush_hour,
        time_of_day
    from {{ ref('int_collisions') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.time_key = target_table.time_key
    )
{% endif %}
