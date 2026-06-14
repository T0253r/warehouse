with stg_vehicles as (
    select * from {{ ref('stg_dft__vehicles') }}
),

dim_collision_dynamics as (
    select distinct
        {{ dbt_utils.generate_surrogate_key([
            'first_point_of_impact'
        ]) }} as dynamics_key,
        first_point_of_impact
    from stg_vehicles
)

select * from dim_collision_dynamics