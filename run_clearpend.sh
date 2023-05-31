#!/bin/bash


sacct | grep -i pending | while read -r line ; do
    echo "Processing $line"
    JOBID=$(echo $line | cut -d' ' -f1)
    scancel $JOBID
done


exit
