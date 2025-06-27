with source as (
    select * from {{ ref('raw_pcns') }}
),

pcns as (
    select 
        id as pcn_id,
        pcn_name
    from source
)

select * from pcns 