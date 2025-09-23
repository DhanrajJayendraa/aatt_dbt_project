



select
    1
from DJ_WORK_DB.PUBLIC.metrics_gates

where not(accuracy between 0 and 1 and fpr between 0 and 1 and fnr between 0 and 1 and tpr between 0 and 1 and tnr between 0 and 1)

