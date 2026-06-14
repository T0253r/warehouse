{{ config(materialized='view') }}

with source as (
    select * from {{ source('stats19', 'collisions') }}
)
select * from source
