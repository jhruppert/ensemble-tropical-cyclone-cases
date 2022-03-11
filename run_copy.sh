#!/bin/bash

# Copy files to archive/transfer them via Globus

#storm="maria"
storm="haiyan"
test_name='ctl'
#test_name='ncrf'
#test_name='wsm6'

# Directories
  maindir="/scratch/06040/tg853394/wrfenkf/ensemble"
  ensdir="${maindir}/${storm}"
  copydir="${maindir}/for_archiving/${storm}/"


for em in 0{1..9} {10..20}; do # Ensemble member
#for em in 0{2..5}; do

  cd $copydir

  dir="memb_${em}"
  mkdir -p $dir
  cd $dir
  dir="${test_name}"
  mkdir -p $dir
  cd $dir

  origin="${ensdir}/memb_${em}/${test_name}"

#  cp ${origin}/azim_* .
#  rsync -av ${origin}/post .

  #SPECIAL TESTS
  if [ ${em} -le 5 ]; then

    cd ../

    test2="ncrf"

    dir="${test2}"
    mkdir -p $dir
exit
    cd $dir

    origin="${ensdir}/memb_${em}/${test_name}"

    cp ${origin}/azim_* . 
    rsync -av ${origin}/post . 

    # A POSSIBLE SECOND TEST
    if [ ${em} -eq "05" ]; then

      test2="crfon"

      dir="${test2}"
      mkdir -p $dir
  
      cd $dir
  
      origin="${ensdir}/memb_${em}/${test_name}"
  
      cp ${origin}/azim_* .
      rsync -av ${origin}/post .

    fi

  fi

done

exit

