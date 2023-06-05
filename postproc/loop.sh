o=0
#ALL 2D+3D
for v in loopvars; do
  ncl process_wrf.ncl v=$v 'd="'${dom}'"' &
  o=$((o+${del}))
  if [ $o -ge SMN ]; then
    wait # wait for jobs to finish before starting next batch
    o=0
  fi
done

wait
