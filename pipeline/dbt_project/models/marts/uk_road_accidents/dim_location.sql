with stg_collisions as (
    select * from {{ ref('stg_dft__collisions') }}
),

dim_location as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'longitude', 
            'latitude', 
            'police_force', 
            'local_authority_district'
        ]) }} as location_key,
        longitude,
        latitude,
        police_force,
        local_authority_district
    from stg_collisions
)

select * from dim_location