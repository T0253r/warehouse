-- with source as (
--         select * from {{ source('data_guide', 'table_desc') }}
--   ),
--   renamed as (
--       select
          

--       from source
--   )
--   select * from renamed

--This will do for now
select * from {{ source('data_guide', 'table_desc') }}