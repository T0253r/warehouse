with source as (
    select * from {{ source('dft', 'casualty') }}
),

renamed as (
    select
    
        {{ dbt_utils.generate_surrogate_key(['collision_index', 'casualty_reference']) }} as casualty_key,
        
        collision_index,
        collision_year,
        collision_ref_no,
        vehicle_reference,
        casualty_reference,
        casualty_class,
        sex_of_casualty,
        age_of_casualty,
        age_band_of_casualty,
        casualty_severity,
        pedestrian_location,
        pedestrian_movement,
        car_passenger,
        bus_or_coach_passenger,
        pedestrian_road_maintenance_worker,
        casualty_type,
        casualty_imd_decile,
        lsoa_of_casualty,
        enhanced_casualty_severity,
        casualty_injury_based,
        casualty_adjusted_severity_serious,
        casualty_adjusted_severity_slight,
        casualty_distance_banding
    from source
)

select * from renamed