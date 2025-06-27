with source as (
    select * from {{ ref('raw_patients') }}
),

patients as (
    select
        try_cast(json_extract(data, '$.patient_id') as integer) as patient_id,
        try_cast(json_extract(data, '$.practice_id') as integer) as practice_id,
        try_cast(json_extract(data, '$.age') as integer) as age,
        lower(json_extract_string(data, '$.gender')) as gender,
        json_extract_string(data, '$.registration_date') as registration_date,
        json_extract(data, '$.conditions') as conditions,
        json_extract(data, '$.contact') as contact
    from source
)

select * from patients 