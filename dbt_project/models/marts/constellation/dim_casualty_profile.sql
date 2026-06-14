{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        casualty_profile_key,
        casualty_class,
        casualty_type,
        sex_of_casualty,
        age_of_casualty,
        age_band_of_casualty,
        casualty_severity,
        pedestrian_location,
        pedestrian_movement,
        car_passenger,
        casualty_distance_banding
    from {{ ref('int_casualties') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.casualty_profile_key = target_table.casualty_profile_key
    )
{% endif %}
