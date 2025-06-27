with patients as (
    select * from {{ ref('stg_patients') }}
),

practices as (
    select * from {{ ref('stg_practices') }}
),

deduped as (
    select
        patient_id,
        practice_id,
        age,
        gender,
        registration_date,
        conditions,
        contact,
        row_number() over (
            partition by patient_id 
            order by registration_date desc
        ) as rn
    from patients
),

valid_practices as (
    select
        d.*
    from deduped d
    inner join practices p
        on d.practice_id = p.practice_id
),

final as (
    select
        patient_id,
        practice_id,
        age,
        case
            when age between 0 and 18 then '0-18'
            when age between 19 and 35 then '19-35'
            when age between 36 and 50 then '36-50'
            when age >= 51 then '51+'
            else null
        end as age_group,
        case
            when gender in ('m', 'f') then gender
            else null
        end as gender,
        registration_date,
        conditions,
        {{ clean_phone_number('json_extract_string(contact, \'$.phone\')') }} as phone_number,
        json_extract_string(contact, '$.email') as email
    from valid_practices
    where rn = 1
      and patient_id is not null
      and practice_id is not null
      and age is not null
      and age between 0 and 120
)

select * from final 