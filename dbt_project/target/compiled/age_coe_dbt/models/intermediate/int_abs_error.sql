




  

  

  

  

  

  

  

  

  

  

  

  

  

  

  

  





with
base as (
  select * from DJ_WORK_DB.PUBLIC.stg_results
),

raw_pred as (
  select
    id,
    
      null::float as predicted_age_years
    
  from DJ_WORK_DB.PUBLIC.RAW_RESULTS
),

joined as (
  select
    b.*,
    r.predicted_age_years
  from base b
  left join raw_pred r using (id)
)

select
  *,
  case
    when predicted_age_years is not null and subject_age_years is not null
      then abs(predicted_age_years - subject_age_years)
    else null
  end as absolute_error
from joined