{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        dynamics_key,
        skidding_and_overturning,
        hit_object_in_carriageway,
        vehicle_leaving_carriageway,
        hit_object_off_carriageway,
        first_point_of_impact
    from {{ ref('int_vehicles') }}
)

SELECT * FROM source_data

{% if is_incremental() %}
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} AS target_table 
        WHERE source_data.dynamics_key = target_table.dynamics_key
    )
{% endif %}
