o=0
#ALL 2D+3D
#for v in {1..3} {8..23} 25 {27..29} 32 33 {36..51} 53; do   #variable id to process
for v in 53; do
#  ibrun -n 1 -o $o 
  ncl process_wrf.ncl v=$v 'd="'${dom}'"' &
#  o=$((o+${del}))
#  if [ $o -ge ${SLURM_NTASKS} ]; then
#    wait   #wait for jobs to finish before starting next batch
#    o=0
#  fi
done

wait
