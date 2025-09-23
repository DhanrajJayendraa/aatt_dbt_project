



select
    1
from DJ_WORK_DB.PUBLIC.stg_results

where not(subject_age_years is null or (subject_age_years between 0 and 110))

