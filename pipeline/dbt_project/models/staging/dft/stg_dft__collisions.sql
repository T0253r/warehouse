with source as (
    select * from {{ source('dft', 'collision') }}
),

renamed as (
    select

        {{ dbt_utils.generate_surrogate_key(['collision_index']) }} as collision_key,
        collision_index,
        
        cast({{ adapter.quote('date') }} as date) as collision_date,
        cast({{ adapter.quote('time') }} as time) as collision_time,
        
        cast(longitude as float) as longitude,
        cast(latitude as float) as latitude,

        collision_year,
        collision_ref_no,
        -- location_easting_osgr,
        -- location_northing_osgr,
        police_force,
        collision_severity,
        -- enhanced_severity_collision,
        number_of_vehicles,
        number_of_casualties,
        day_of_week,
        local_authority_district,
        -- local_authority_ons_district,
        -- local_authority_highway,
        -- local_authority_highway_current,
        first_road_class,
        first_road_number,
        road_type,
        speed_limit,
        -- junction_detail_historic,
        -- junction_detail,
        -- junction_control,
        second_road_class,
        second_road_number,
        -- pedestrian_crossing_human_control_historic,
        -- pedestrian_crossing_physical_facilities_historic,
        -- pedestrian_crossing,
        light_conditions,
        weather_conditions,
        road_surface_conditions,
        special_conditions_at_site,
        -- carriageway_hazards_historic,
        -- carriageway_hazards,
        -- urban_or_rural_area,
        -- did_police_officer_attend_scene_of_accident,
        -- trunk_road_flag,
        -- lsoa_of_accident_location,
        -- collision_injury_based,
        -- collision_adjusted_severity_serious,
        -- collision_adjusted_severity_slight

    from source
)

select * from renamed