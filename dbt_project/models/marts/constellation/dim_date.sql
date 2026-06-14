{{ config(materialized='table') }}

WITH source_data AS (
    {{ dbt_date.get_date_dimension("1940-01-01", "2200-12-31") }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(["strftime(date_day, '%d/%m/%Y')"]) }} AS date_key,
    *
FROM source_data