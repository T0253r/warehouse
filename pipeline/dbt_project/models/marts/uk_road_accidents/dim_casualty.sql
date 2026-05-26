with stg_casualties as (
    select * from {{ ref('stg_dft__casualties') }}
),

dim_casualty as (
    select
        casualty_key,  -- Primary key (already generated in staging)

        casualty_class,
        casualty_type,
        sex_of_casualty,
        age_of_casualty,
        age_band_of_casualty,
        casualty_severity

    from stg_casualties
)

select * from dim_casualty