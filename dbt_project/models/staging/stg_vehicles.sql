{{ config(materialized='view') }}

with source as (
    select * from {{ source('stats19', 'vehicles') }}
)
select * from source
