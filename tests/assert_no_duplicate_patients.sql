-- Custom test to ensure no duplicate patients
select patient_id, count(*) as count
from {{ ref('int_patients_clean') }}
group by patient_id
having count(*) > 1 