with activities as (
    select * from {{ ref('int_activities_clean') }}
),

patients as (
    select * from {{ ref('dim_patients') }}
),

final as (
    select
        a.activity_id,
        a.patient_id,
        a.activity_type,
        a.activity_date,
        a.duration_minutes
    from activities a
    inner join patients p
        on a.patient_id = p.patient_id
)

select * from final 