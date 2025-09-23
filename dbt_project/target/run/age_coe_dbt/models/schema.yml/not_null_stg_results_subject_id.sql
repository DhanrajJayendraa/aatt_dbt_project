
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select subject_id
from DJ_WORK_DB.PUBLIC.stg_results
where subject_id is null



  
  
      
    ) dbt_internal_test