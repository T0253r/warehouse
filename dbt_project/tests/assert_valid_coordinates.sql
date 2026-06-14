-- Singular test: Longitude and Latitude should be within valid UK bounds if they are provided.
-- UK approximate bounds: Longitude (-9 to 2), Latitude (49 to 61)
-- If this query returns any rows, the test fails.

select
    location_key,
    longitude,
    latitude
from {{ ref('dim_location') }}
where 
    (longitude is not null and (longitude < -10 or longitude > 5))
    or 
    (latitude is not null and (latitude < 49 or latitude > 62))
