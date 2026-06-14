-- Singular test: Fatalities should never exceed the total number of casualties in a single collision
-- If this query returns any rows, the test fails.

select
    collision_index,
    number_of_casualties,
    number_of_fatalities
from {{ ref('fact_collision') }}
where number_of_fatalities > number_of_casualties
