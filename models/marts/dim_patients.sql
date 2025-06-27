-- Dimension table for patients
with patients as (
    select * from {{ ref('int_patients_clean') }}
),

practices as (
    select * from {{ ref('dim_practices') }}
),

final as (
    select
        p.patient_id,
        p.practice_id,
        p.age,
        p.age_group,
        p.gender,
        p.registration_date,
        p.conditions,
        p.phone_number,
        p.email
    from patients p
    -- CRITICAL: Inner join ensures only patients with valid practices are included
    inner join practices pr on p.practice_id = pr.practice_id
)

select * from final 