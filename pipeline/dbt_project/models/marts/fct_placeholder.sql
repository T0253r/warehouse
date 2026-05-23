SELECT
    accident_id,
    accident_date,
    severity
FROM {{ ref('stg_placeholder') }}