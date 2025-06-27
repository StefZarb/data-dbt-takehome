with patients as (
    select * from {{ ref('dim_patients') }}
),

practices as (
    select * from {{ ref('dim_practices') }}
),

pcns as (
    select * from {{ ref('dim_pcns') }}
),

final as (
    select
        pcns.pcn_name,
        patients.age_group,
        count(distinct patients.patient_id) as total_patients
    from patients
    inner join practices
        on patients.practice_id = practices.practice_id
    inner join pcns
        on practices.pcn_id = pcns.pcn_id
    where patients.age_group is not null
    group by pcns.pcn_name, patients.age_group
)

select * from final 