{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        vehicle_profile_key,
        vehicle_type,
        junction_location,
        vehicle_left_hand_drive,
        sex_of_driver,
        age_of_driver,
        age_band_of_driver,
        engine_capacity_cc,
        propulsion_code,
        age_of_vehicle,
        driver_distance_banding,
        engine_capacity_banding,
        age_band_of_vehicle
    from {{ ref('int_vehicles') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.vehicle_profile_key = target_table.vehicle_profile_key
    )
{% endif %}
