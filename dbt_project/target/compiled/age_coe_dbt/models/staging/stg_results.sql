with raw as (
  select * from DJ_WORK_DB.PUBLIC.RAW_RESULTS
),
typed as (
  select
    id, custom_id, create_user,
    try_to_timestamp_ntz(to_varchar(result_time)) as result_time,
    name, method,
    case method when 'AE' then 'Estimation' when 'AV' then 'Verification'
               when 'AI' then 'Inference' else method end as method_norm,
    try_to_number(to_varchar(age_gate)) as age_gate,
    subject_id,
    try_to_date(to_varchar(date_of_birth)) as date_of_birth,
    try_to_number(to_varchar(age_in_months)) as age_in_months_num,
    country_of_birth_subject, country_of_birth_mother, country_of_birth_father,
    origin,
    verification_time, verification_status,
    case lower(verification_status) when 't' then true when 'true' then true
                                    when 'f' then false when 'false' then false
                                    else null end as verification_status_bool_raw,
    try_to_number(to_varchar(reported_age)) as reported_age,
    result_label, verification_data
  from raw
),
calc as (
  -- compute candidate age; use months when sane, else DOB vs result_time, else null
  select
    *,
    case
      when age_in_months_num between 0 and 150*12
        then age_in_months_num / 12.0
      when date_of_birth is not null and result_time is not null
           and datediff('day', date_of_birth, result_time) between 0 and 150*365
        then datediff('day', date_of_birth, result_time) / 365.25
      else null
    end as subject_age_years_raw
  from typed
)
select
  id, custom_id, create_user, result_time, name, method, method_norm, age_gate,
  subject_id, date_of_birth, age_in_months_num as age_in_months,
  country_of_birth_subject, country_of_birth_mother, country_of_birth_father,
  origin, verification_time, verification_status, verification_status_bool_raw,
  reported_age, result_label, verification_data,

  -- hard clamp to [0,110]; otherwise set null so tests & marts stay sane
  case
    when subject_age_years_raw between 0 and 110 then subject_age_years_raw
    else null
  end as subject_age_years,

  case when 'false' ilike 'true'
       then not verification_status_bool_raw else verification_status_bool_raw end
  as verification_status_bool,

  case when verification_time is null then null else
    split_part(verification_time,':',1)::int * 3600 +
    split_part(verification_time,':',2)::int * 60 +
    split_part(verification_time,':',3)::float end as verification_seconds
from calc