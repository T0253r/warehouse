WITH raw_data AS (
    -- Read the CSV safely as text strings. 
    -- Path is relative to the dbt_project folder where you run the command!
    SELECT * FROM read_csv_auto('{{ env_var("MAIN_PROJECT_ROOT_DIR") }}/data/archive/messy_test.csv', all_varchar=true)
),

resolved_severities AS (
    -- Resolve the messy strings against our seed file
    SELECT 
        raw_val,
        COALESCE(
            (SELECT standard_name FROM {{ ref('map_severity') }} WHERE UPPER(input_value) = UPPER(raw_val)),
            'Unknown / Invalid Input'
        ) AS clean_severity_name
    FROM (SELECT DISTINCT severity_code AS raw_val FROM raw_data WHERE severity_code IS NOT NULL)
)

-- Glue the clean data together
SELECT 
    raw.accident_id,
    TRY_CAST(raw.accident_date AS DATE) AS accident_date,
    res.clean_severity_name AS severity
FROM raw_data AS raw
LEFT JOIN resolved_severities AS res 
    ON raw.severity_code = res.raw_val