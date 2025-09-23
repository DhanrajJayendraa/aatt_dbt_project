
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from DJ_WORK_DB.PUBLIC.stg_results

where not(subject_age_years between 0 and 110)


  
  
      
    ) dbt_internal_test