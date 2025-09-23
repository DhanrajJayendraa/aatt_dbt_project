
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from DJ_WORK_DB.PUBLIC.stg_results

where not(verification_seconds is null or verification_seconds >= 0)


  
  
      
    ) dbt_internal_test