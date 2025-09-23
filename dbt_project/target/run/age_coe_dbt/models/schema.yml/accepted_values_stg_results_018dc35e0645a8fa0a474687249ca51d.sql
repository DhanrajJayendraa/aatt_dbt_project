
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        method_norm as value_field,
        count(*) as n_records

    from DJ_WORK_DB.PUBLIC.stg_results
    group by method_norm

)

select *
from all_values
where value_field not in (
    'Estimation','Verification','Inference'
)



  
  
      
    ) dbt_internal_test