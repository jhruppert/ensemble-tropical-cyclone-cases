#!/bin/bash
#SBATCH -J idl_azim
#SBATCH -N 6
#SBATCH -n 288
#192
#SBATCH -p skx-normal
#SBATCH -t 04:00:00 # runtime
#SBATCH -o out_azim.%j
##SBATCH --dependency=afterok:6416300

# ~8 hours for 20 ensemble members over 6 simulated days

module load idl

idl_runfile="idl_run_azim.pro"

del=12 # number of nodes per idl call

o=0
for ens in 0{1..9} {10..20}; do # Ensemble members
#for ens in {15..20}; do # Ensemble members

  #Replace ensemble selection
  sed -i "/member/c\ensmemb=${ens} ; Set ensemble member" ${idl_runfile}

for v in {0..12}; do # Variables

  #Replace variable selection
  sed -i "/process/c\iv_calc=${v} ; Set variable to process" ${idl_runfile}

  ibrun -n 1 -o $o idl < ${idl_runfile} &

  o=$((o+${del}))
  if [ $o -ge ${SLURM_NTASKS} ]; then
    wait   #wait for jobs to finish before starting next batch
    o=0
  fi

done
done

wait
