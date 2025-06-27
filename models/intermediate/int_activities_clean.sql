with activities as (
    select * from {{ ref('stg_activities') }}
),

patients as (
    select * from {{ ref('int_patients_clean') }}
),

cleaned as (
    select
        cast(activity_id as integer) as activity_id,
        cast(patient_id as integer) as patient_id,
        activity_type,
        cast(activity_date as timestamp) as activity_date,
        abs(cast(duration_minutes as integer)) as duration_minutes
    from activities
    where activity_id is not null
        and patient_id is not null
        and activity_date is not null
        and duration_minutes != 0
        and activity_type in ('consultation', 'prescription', 'lab_test', 'intro_call')
),

valid_activities as (
    select a.*
    from cleaned a
    inner join patients p
        on a.patient_id = p.patient_id
),

final as (
    select * from valid_activities
)

select * from final 