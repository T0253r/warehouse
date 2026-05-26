with stg_vehicles as (
    select * from {{ ref('stg_dft__vehicles') }}
),

dim_pre_collision_motion as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'junction_location'
        ]) }} as motion_key,
        junction_location
    from stg_vehicles
)

select * from dim_pre_collision_motion