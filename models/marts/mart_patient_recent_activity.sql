with activities as (
    select * from {{ ref('fact_activities') }}
),

patients as (
    select * from {{ ref('dim_patients') }}
),

practices as (
    select * from {{ ref('dim_practices') }}
),

recent_activities as (
    select
        patient_id,
        max(activity_date) as most_recent_activity_date,
        count(*) as total_activities
    from activities
    group by patient_id
),

final as (
    select
        p.patient_id,
        p.practice_id,
        pr.practice_name,
        p.age,
        p.age_group,
        p.gender,
        p.registration_date,
        r.most_recent_activity_date,
        r.total_activities,
        -- Days since last activity
        case 
            when r.most_recent_activity_date is not null 
            then date_diff('day', cast(r.most_recent_activity_date as date), current_date)
            else null
        end as days_since_last_activity
    from patients p
    left join recent_activities r on p.patient_id = r.patient_id
    left join practices pr on p.practice_id = pr.practice_id
    order by r.most_recent_activity_date desc nulls last
)

select * from final 
