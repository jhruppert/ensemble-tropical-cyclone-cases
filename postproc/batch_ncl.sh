#!/bin/bash
#SBATCH -J ncl
#SBATCH -N 4
#SBATCH -n 192
#192 for N=4
#SBATCH -p skx-normal
#SBATCH -t 01:30:00 # runtime
#SBATCH -o out_ncl.%j
##SBATCH --dependency=afterok:6416300

# Process WRF output

module load ncl_ncarg

dom="d02"

del=12 # number of nodes per ncl call
#8 for MCwaves
#12 for Maria

o=0
#ALL 2D+3D Meiyu
for v in {1..3} {8..16} {21..23} 25 {27..29} 32 33 {36..51}; do   #variable id to process
# SINGLE
#for v in 19 20; do   #variable id to process
#ncl process_wrf.ncl v=$v 'd="'${dom}'"'
  ibrun -n 1 -o $o ncl process_wrf.ncl v=$v 'd="'${dom}'"' &
  o=$((o+${del}))
  if [ $o -ge ${SLURM_NTASKS} ]; then
    wait   #wait for jobs to finish before starting next batch
    o=0
  fi
done

wait
