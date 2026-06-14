with stg_casualties as (
    select * from {{ ref('stg_dft__casualties') }}
),

dim_casualty_profile as (
    select
        casualty_key as casualty_profile_key,

        casualty_class,
        casualty_type,
        sex_of_casualty,
        age_of_casualty,
        age_band_of_casualty,
        casualty_severity

    from stg_casualties
)

select * from dim_casualty_profile
