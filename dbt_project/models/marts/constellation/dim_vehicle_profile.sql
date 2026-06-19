{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        vehicle_profile_key,
        {{ map_id('vehicle', 'vehicle_type') }} as vehicle_type,
        {{ map_id('vehicle', 'junction_location') }} as junction_location,
        {{ map_id('vehicle', 'vehicle_left_hand_drive') }} as vehicle_left_hand_drive,
        {{ map_id('vehicle', 'sex_of_driver') }} as sex_of_driver,
        age_of_driver,
        {{ map_id('vehicle', 'age_band_of_driver') }} as age_band_of_driver,
        engine_capacity_cc,
        {{ map_id('vehicle', 'propulsion_code') }} as propulsion_code,
        age_of_vehicle,
        {{ map_id('vehicle', 'driver_distance_banding') }} as driver_distance_banding,
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
