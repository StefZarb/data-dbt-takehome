with practices as (
    select * from {{ ref('stg_practices') }}
),

pcns as (
    select * from {{ ref('dim_pcns') }}
),

final as (
    select
        practices.pcn as pcn_id,
        practices.practice_id,
        practices.practice_name,
        practices.location,
        practices.established_date
    from practices
    inner join pcns
        on pcns.pcn_id = practices.pcn
)

select * from final 