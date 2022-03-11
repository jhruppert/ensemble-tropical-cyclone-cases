#!/bin/bash


sacct | grep -i pending | while read -r line ; do
    echo "Processing $line"
    # your code goes here
    JOBID=$(echo $line | cut -d' ' -f1)
    echo "Cancelling $JOBID"
    scancel $JOBID
done


exit
