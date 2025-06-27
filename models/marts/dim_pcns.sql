with pcns as (
    select * from {{ ref('stg_pcns') }}
),

final as (
    select
        pcn_id,
        pcn_name
    from pcns
)

select * from final 