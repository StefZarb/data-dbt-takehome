-- Custom test to ensure no invalid activity durations
select activity_id, duration_minutes
from {{ ref('fact_activities') }}
where duration_minutes < 0 or duration_minutes is null 