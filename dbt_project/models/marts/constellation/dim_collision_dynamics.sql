{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH source_data AS (
    select distinct
        dynamics_key,
        {{ map_id('vehicle', 'skidding_and_overturning') }} as skidding_and_overturning,
        {{ map_id('vehicle', 'hit_object_in_carriageway') }} as hit_object_in_carriageway,
        {{ map_id('vehicle', 'vehicle_leaving_carriageway') }} as vehicle_leaving_carriageway,
        {{ map_id('vehicle', 'hit_object_off_carriageway') }} as hit_object_off_carriageway,
        {{ map_id('vehicle', 'first_point_of_impact') }} as first_point_of_impact
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
