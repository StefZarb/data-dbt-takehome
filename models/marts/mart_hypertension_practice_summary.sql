with patients as (
    select * from {{ ref('dim_patients') }}
),

practices as (
    select * from {{ ref('dim_practices') }}
),

final as (
    select
        practices.practice_name,
        round(
            (count(distinct case when patients.conditions::varchar like '%hypertension%' then patients.patient_id end) * 100.0) / 
            count(distinct patients.patient_id), 
            2
        ) as hypertension_percentage
    from patients
    inner join practices
        on patients.practice_id = practices.practice_id
    group by practices.practice_name
)

select * from final
order by hypertension_percentage desc 