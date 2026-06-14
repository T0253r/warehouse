{{ config(materialized='view') }}

with source as (
    select * from read_csv_auto('/home/t0253r/data/dft_incremental/dft-road-casualty-statistics-vehicle-*.csv', all_varchar=true)
)
select * from source
