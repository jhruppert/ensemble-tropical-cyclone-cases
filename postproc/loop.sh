o=0
#ALL 2D+3D
for v in loopvars; do
  # ibrun -n 1 -o $o 
  ncl process_wrf.ncl v=$v 'd="'${dom}'"' &
  # mpirun -np ${del} ncl process_wrf.ncl v=$v 'd="'${dom}'"' &
  o=$((o+${del}))
  if [ $o -ge SLURM_NTASKS ]; then
    wait   #wait for jobs to finish before starting next batch
    o=0
  fi
done

wait
