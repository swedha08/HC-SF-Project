with source as (
    select * from {{ source('raw', 'encounters') }}
),

deduped as (
    select *
    from source
    qualify row_number() over (
        partition by encounter_id
        order by encounter_date desc nulls last
    ) = 1
),

cleaned as (
    select
        upper(trim(encounter_id))                       as encounter_id,
        upper(trim(patient_id))                          as patient_id,

        coalesce(
            try_to_date(encounter_date, 'YYYY-MM-DD'),
            try_to_date(encounter_date, 'MM/DD/YYYY')
        )                                                  as encounter_date,

        initcap(trim(encounter_type))                        as encounter_type,
        nullif(trim(diagnosis_code), '')                       as diagnosis_code,
        initcap(trim(department))                                as department,
        initcap(trim(attending_physician))                        as attending_physician,

        case
            when try_to_number(billed_amount) < 0 then null
            else try_to_number(billed_amount)
        end                                                          as billed_amount,

        initcap(trim(payment_status))                                  as payment_status,

        coalesce(
            try_to_date(discharge_date, 'YYYY-MM-DD'),
            try_to_date(discharge_date, 'MM/DD/YYYY')
        )                                                                  as discharge_date

    from deduped
),

valid_patients as (
    select patient_id from {{ ref('stg_patients') }}
)

select c.*
from cleaned c
inner join valid_patients p
    on c.patient_id = p.patient_id
where c.patient_id is not null