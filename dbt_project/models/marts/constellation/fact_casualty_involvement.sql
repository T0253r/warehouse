{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select
        casualty_involvement_key,
        collision_index,
        date_key,
        time_key,
        location_key,
        infrastructure_key,
        condition_key,
        casualty_profile_key,
        vehicle_profile_key
    from {{ ref('int_casualties') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.casualty_involvement_key = target_table.casualty_involvement_key
    )
{% endif %}
