#!/bin/bash


#sacct | grep -i haiy | grep -i runn | while read -r line ; do
sacct | grep -i runn | while read -r line ; do
    echo "Processing $line"
    JOBID=$(echo $line | cut -d' ' -f1)
    echo $JOBID
    scancel $JOBID
done


exit
