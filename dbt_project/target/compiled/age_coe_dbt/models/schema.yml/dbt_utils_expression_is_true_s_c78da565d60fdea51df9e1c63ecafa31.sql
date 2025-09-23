



select
    1
from DJ_WORK_DB.PUBLIC.stg_results

where not(verification_seconds is null or verification_seconds >= 0)

