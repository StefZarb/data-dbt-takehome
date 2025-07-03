with patients as (
    select * from {{ ref('dim_patients') }}
),

activities as (
    select * from {{ ref('fact_activities') }}
),

patient_first_activity as (
    select
        patient_id,
        min(activity_date) as first_activity_date
    from activities
    group by patient_id
),

patient_activity_after_first as (
    select
        a.patient_id,
        a.activity_date,
        pfa.first_activity_date,
        (a.activity_date - pfa.first_activity_date) as days_after_first
    from activities a
    inner join patient_first_activity pfa
        on a.patient_id = pfa.patient_id
    where a.activity_date > pfa.first_activity_date  -- Activities AFTER first activity
),

patients_with_activity_after_3_months as (
    select distinct
        patient_id,
        min(activity_date) as last_activity_date  -- First activity after 3-month gap
    from patient_activity_after_first
    where days_after_first >= interval '3 months'
    group by patient_id
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
        p.email,
        pfa.first_activity_date,
        pwa3m.last_activity_date
    from patients p
    inner join patient_first_activity pfa
        on p.patient_id = pfa.patient_id
    inner join patients_with_activity_after_3_months pwa3m
        on p.patient_id = pwa3m.patient_id
)

select * from final