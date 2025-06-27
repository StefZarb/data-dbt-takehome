with source as (
    select * from {{ ref('raw_practices') }}
),

practices as (
    select
        id as practice_id,
        practice_name,
        location,
        established_date,
        pcn
    from source
)

select * from practices 