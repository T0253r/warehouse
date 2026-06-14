{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select
        vehicle_involvement_key,
        collision_index,
        date_key,
        time_key,
        location_key,
        infrastructure_key,
        condition_key,
        vehicle_profile_key,
        dynamics_key
    from {{ ref('int_vehicles') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.vehicle_involvement_key = target_table.vehicle_involvement_key
    )
{% endif %}
