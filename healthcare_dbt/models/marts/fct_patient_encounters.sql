with patients as (
    select * from {{ ref('stg_patients') }}
),

encounters as (
    select * from {{ ref('stg_encounters') }}
)

select
    e.encounter_id,
    e.patient_id,
    p.first_name,
    p.last_name,
    p.gender,
    p.date_of_birth,
    p.insurance_provider,
    e.encounter_date,
    e.encounter_type,
    e.diagnosis_code,
    e.department,
    e.attending_physician,
    e.billed_amount,
    e.payment_status,
    e.discharge_date
from encounters e
left join patients p
    on e.patient_id = p.patient_id