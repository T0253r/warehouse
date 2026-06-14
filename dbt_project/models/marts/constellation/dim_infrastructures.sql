{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        infrastructure_key,
        road_type,
        speed_limit,
        junction_detail,
        junction_control
    from {{ ref('int_collisions') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.infrastructure_key = target_table.infrastructure_key
    )
{% endif %}
