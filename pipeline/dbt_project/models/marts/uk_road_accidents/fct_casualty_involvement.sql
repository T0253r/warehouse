with stg_casualties as (

    select * from {{ ref('stg_dft__casualties') }}

),

fact_casualty_involvement as (

    select
        -- Primary Key
        casualty_key,

        -- Natural Keys (Kept for traceability/debugging)
        collision_index,
        vehicle_reference,
        casualty_reference,

        -- Foreign Keys bridging up to the Level 1 & 2 Fact/Dimension tables
        collision_key,
        vehicle_key

    from stg_casualties

)

select * from fact_casualty_involvement