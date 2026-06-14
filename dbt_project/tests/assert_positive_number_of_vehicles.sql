-- Singular test: Every collision must involve at least one vehicle.
-- If this query returns any rows, the test fails.

select
    collision_index,
    number_of_vehicles
from {{ ref('fact_collision') }}
where number_of_vehicles < 1
