with stg_vehicles as (

    select * from {{ ref('stg_dft__vehicles') }}

),

fact_vehicle_involvement as (

    select
        -- Primary Key
        vehicle_key,

        -- Natural Keys
        collision_index,
        vehicle_reference,
        
        -- Foreign Key bridging up to the Level 1 Fact Collision
        collision_key,

        -- Foreign Keys to Vehicle-specific Profile Dimensions
        {{ dbt_utils.generate_surrogate_key([
            'junction_location'
        ]) }} as motion_key,

        {{ dbt_utils.generate_surrogate_key([
            'first_point_of_impact'
        ]) }} as dynamics_key

    from stg_vehicles

)

select * from fact_vehicle_involvement