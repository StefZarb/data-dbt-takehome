with patients as (
    select * from {{ ref('dim_patients') }}
),

activities as (
    select * from {{ ref('fact_activities') }}
),

latest_activity as (
    select
        patient_id,
        max(activity_date) as last_activity_date
    from activities
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
        la.last_activity_date
    from patients p
    left join latest_activity la
        on p.patient_id = la.patient_id
    where
        la.last_activity_date is null
        or la.last_activity_date < (current_date - interval '3 months')
)

select * from final 