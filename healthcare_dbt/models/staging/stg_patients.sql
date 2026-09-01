with source as (
    select * from {{ source('raw', 'patients') }}
),

deduped as (
    select *,
        row_number() over (
            partition by patient_id
            order by updated_at desc nulls last
        ) as row_num
    from source
),

cleaned as (
    select
        upper(trim(patient_id))                          as patient_id,
        initcap(trim(first_name))                         as first_name,
        initcap(trim(last_name))                          as last_name,

        coalesce(
            try_to_date(dob, 'YYYY-MM-DD'),
            try_to_date(dob, 'MM-DD-YYYY'),
            try_to_date(dob, 'YYYY/MM/DD')
        )                                                  as date_of_birth,

        case
            when upper(trim(gender)) in ('M','MALE') then 'M'
            when upper(trim(gender)) in ('F','FEMALE') then 'F'
            else 'Unknown'
        end                                                as gender,

        nullif(trim(ssn), '')                              as ssn,
        nullif(trim(phone), '')                             as phone,
        lower(nullif(trim(email), ''))                       as email,
        trim(address)                                         as address,
        trim(city)                                             as city,
        trim(state)                                             as state,
        trim(zip)                                                as zip,
        nullif(trim(insurance_provider), '')                      as insurance_provider,

        try_to_timestamp(created_at)                               as created_at,
        try_to_timestamp(updated_at)                                as updated_at

    from deduped
    where row_num = 1   -- keep only the latest version of each patient_id
)

select * from cleaned