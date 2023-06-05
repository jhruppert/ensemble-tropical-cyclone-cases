#!/bin/bash
#SBATCH -J m01-ncl
#SBATCH --nodes 1
#SBATCH --ntasks 56
#SBATCH --ntasks-per-node=56
#SBATCH -p radclouds
#SBATCH -t 01:30:00
#SBATCH -o out_ncl.%j
#SBATCH --exclusive
### SBATCH --dependency=afterany:

source /home/jamesrup/ensemble-tropical-cyclone-cases/bashrc_wrf

module load NCL

dom="d02"

# Link first time step for mechanism denial tests for writing post-processed output
if [[ "ncrf36h" == *'crf'* ]] || [[ "ncrf36h" == *'STRAT'* ]]; then
  ln -sf /tc_ens/haiyan/memb_01/ctl/wrfout_d0*_2013-11-02_12:00:00 ../
fi

# Modify NCL file
  sed -i "/Setdays/c\    nd=2 ; Setdays" process_wrf.ncl
  sed -i '/Start time/c\    t0="'201311021200'" ; Start time' process_wrf.ncl
  sed -i '/project directory/c\  dir=".." ; project directory' process_wrf.ncl

del=12 # number of nodes per ncl call

o=0
#ALL 2D+3D
for v in {1..3} {8..23} 25 {27..29} 32 33 {36..51} 53; do
#  ibrun -n 1 -o $o 
  ncl process_wrf.ncl v=$v 'd="'${dom}'"' &
#  o=$((o+${del}))
#  if [ $o -ge ${SLURM_NTASKS} ]; then
#    wait   #wait for jobs to finish before starting next batch
#    o=0
#  fi
done

wait
