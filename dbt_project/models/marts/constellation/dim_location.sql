{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        location_key,
        longitude,
        latitude,
        {{ map_id('collision', 'police_force') }} as police_force,
        {{ map_id('collision', 'local_authority_district') }} as local_authority_district
    from {{ ref('int_collisions') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.location_key = target_table.location_key
    )
{% endif %}
