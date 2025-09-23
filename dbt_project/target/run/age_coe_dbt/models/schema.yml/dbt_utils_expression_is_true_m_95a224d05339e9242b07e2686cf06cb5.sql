
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  



select
    1
from DJ_WORK_DB.PUBLIC.metrics_gates

where not(accuracy between 0 and 1 and fpr between 0 and 1 and fnr between 0 and 1 and tpr between 0 and 1 and tnr between 0 and 1)


  
  
      
    ) dbt_internal_test