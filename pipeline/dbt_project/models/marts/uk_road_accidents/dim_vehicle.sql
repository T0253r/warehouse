with stg_vehicles as (
    select * from {{ ref('stg_dft__vehicles') }}
),

dim_vehicle as (
    select
        vehicle_key,  -- Primary key (already generated in staging)
        
        vehicle_type,
        engine_capacity_cc,
        propulsion_code,
        age_of_vehicle,
        generic_make_model,
        vehicle_left_hand_drive,
        sex_of_driver,
        age_of_driver,
        age_band_of_driver,
        driver_distance_banding
        
    from stg_vehicles
)

select * from dim_vehicle