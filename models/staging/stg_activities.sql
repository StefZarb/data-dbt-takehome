with source as (
    select * from {{ ref('raw_activities') }}
)

select * from source 