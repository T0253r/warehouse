{{ config(materialized='view') }}

with source as (
    select * from {{ source('stats19', 'casualties') }}
)
select * from source
