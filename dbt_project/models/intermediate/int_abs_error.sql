-- models/intermediate/int_abs_error.sql
with base as (
  select * from {{ ref('stg_results') }}
),
est as (
  select
    *,
    case
      when method_norm = 'Estimation'
       and reported_age is not null
       and subject_age_years between 0 and 100
      then abs(reported_age - subject_age_years)
      else null
    end as abs_error
  from base
),
stats as (
  select
    method_norm,
    avg(abs_error) as mean_abs_error,
    stddev_samp(abs_error) as sd_abs_error
  from est
  where abs_error is not null
  group by 1
),
with_flags as (
  select
    e.*,
    s.mean_abs_error,
    s.sd_abs_error,
    case
      when e.abs_error is null then null
      when s.sd_abs_error is null then e.abs_error -- no variance info
      when e.abs_error between (s.mean_abs_error - 2*s.sd_abs_error) and (s.mean_abs_error + 2*s.sd_abs_error)
        then e.abs_error
      else null
    end as abs_error_trimmed
  from est e
  left join stats s using (method_norm)
)
select * from with_flags
