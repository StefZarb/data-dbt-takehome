with patients as (
    select * from {{ ref('dim_patients') }}
),

practices as (
    select * from {{ ref('dim_practices') }}
),

final as (
    select
        practices.practice_name,
        round(avg(patients.age), 0) as average_patient_age
    from patients
    inner join practices
        on patients.practice_id = practices.practice_id
    where patients.age is not null
    group by practices.practice_name
)

select * from final
order by average_patient_age desc 