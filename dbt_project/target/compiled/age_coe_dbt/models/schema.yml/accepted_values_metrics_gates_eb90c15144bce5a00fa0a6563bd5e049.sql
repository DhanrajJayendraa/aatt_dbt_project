
    
    

with all_values as (

    select
        method_norm as value_field,
        count(*) as n_records

    from DJ_WORK_DB.PUBLIC.metrics_gates
    group by method_norm

)

select *
from all_values
where value_field not in (
    'Estimation','Verification','Inference'
)


