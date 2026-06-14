{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        location_key,
        longitude,
        latitude,
        police_force,
        local_authority_district
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
