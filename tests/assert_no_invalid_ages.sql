-- Custom test to ensure no invalid ages
select patient_id, age
from {{ ref('int_patients_clean') }}
where age < 0 or age > 120 or age is null 