#!/bin/bash

storm="maria"
storm="haiyan"

test_name='ctl'
#test_name='ncrf'
#test_name='wsm6'

# Directories
  indir=${SCRATCH}/tc_ens
  outdir=${SCRATCH}/tc_ens_icbc

# All
#for em in 0{1..9} {10..20}; do # Ensemble member
for em in 0{1..9} 10; do # Ensemble member
# Special cases
#for em in 01; do # Ensemble member

  mkdir -p $outdir/$storm
  cd $outdir/$storm

  memdir="memb_${em}"
  mkdir -p $memdir
  cd $memdir

  mkdir -p $test_name
  cd $indir/$storm/$memdir/$test_name/
  mv wrfinput* wrflow* wrfbd* $outdir/$storm/$memdir/$test_name/

done

exit
