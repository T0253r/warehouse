{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        casualty_profile_key,
        {{ map_id('casualty', 'casualty_class') }} as casualty_class,
        {{ map_id('casualty', 'casualty_type') }} as casualty_type,
        {{ map_id('casualty', 'sex_of_casualty') }} as sex_of_casualty,
        age_of_casualty,
        {{ map_id('casualty', 'age_band_of_casualty') }} as age_band_of_casualty,
        {{ map_id('casualty', 'casualty_severity') }} as casualty_severity,
        {{ map_id('casualty', 'pedestrian_location') }} as pedestrian_location,
        {{ map_id('casualty', 'pedestrian_movement') }} as pedestrian_movement,
        {{ map_id('casualty', 'car_passenger') }} as car_passenger,
        {{ map_id('casualty', 'casualty_distance_banding') }} as casualty_distance_banding
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
