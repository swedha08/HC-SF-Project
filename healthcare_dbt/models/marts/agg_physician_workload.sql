with fct as (
    select * from {{ ref('fct_patient_encounters') }}
)

select
    attending_physician,
    department,
    count(*)                                   as total_encounters,
    count(distinct patient_id)                   as unique_patients_seen,
    sum(billed_amount)                             as total_billed
from fct
where attending_physician is not null
group by attending_physician, department
order by total_encounters desc