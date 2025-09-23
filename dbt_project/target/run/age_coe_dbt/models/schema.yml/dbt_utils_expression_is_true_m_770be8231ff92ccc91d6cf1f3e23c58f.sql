
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from DJ_WORK_DB.PUBLIC.metrics_gates

where not(samples = coalesce(tp,0)+coalesce(tn,0)+coalesce(fp,0)+coalesce(fn,0))


  
  
      
    ) dbt_internal_test