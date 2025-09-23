-- models/marts/metrics_estimation.sql
with src as (
  select * from DJ_WORK_DB.PUBLIC.int_abs_error
),
overall as (
  select
    'overall' as slice_type,
    null as gate,
    count_if(abs_error is not null) as samples,
    avg(abs_error_trimmed) as mae_years,
    stddev_samp(abs_error_trimmed) as sd_years
  from src
),
per_gate as (
  -- compute per-gate MAE using truth vs gate thresholds; uses same trimmed error
  select
    'gate' as slice_type,
    g as gate,
    count_if(abs_error is not null) as samples,
    avg(abs_error_trimmed) as mae_years,
    stddev_samp(abs_error_trimmed) as sd_years
  from src,
  lateral flatten(input => array_construct(13,16,18)) f,
  lateral (select f.value::int as g)
  group by 1,2
)
select * from overall
union all
select * from per_gate