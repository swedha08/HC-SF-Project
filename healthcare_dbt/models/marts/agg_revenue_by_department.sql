with fct as (
    select * from {{ ref('fct_patient_encounters') }}
)

select
    department,
    count(*)                         as total_encounters,
    sum(billed_amount)                as total_revenue,
    avg(billed_amount)                 as avg_revenue_per_encounter,
    sum(case when payment_status = 'Paid' then billed_amount else 0 end)   as collected_revenue,
    sum(case when payment_status != 'Paid' then billed_amount else 0 end)   as outstanding_revenue
from fct
where department is not null
group by department
order by total_revenue desc