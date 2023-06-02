#!/bin/bash
#SBATCH -J tar_m
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -o out_tar.%j

# Copy files to archive/transfer them via Globus

#storm="maria"
storm="haiyan"

tcdir="/stornext/ranch_01/ranch/projects/TG-ATM090042/Ruppert/tc_output_ensemb"

#for em in 0{1..9} {10..20}; do # Ensemble member
#for em in 0{2..5}; do # Ensemble member
for em in 05; do # Ensemble member

for dir in haiyan/memb_${em}/*; do

  dir="${dir##*/}"
  checkfil="tar_memb${em}_${storm}_${dir}.complete"

  if ! test -f "${checkfil}"; then
    echo "Running memb_${em}_${storm}/${dir}"
    tar cf "tarballs/memb_${em}_${storm}/${dir}.tar" "${storm}/memb_${em}/${dir}" #> tar_memb${em}_${storm}_${dir}.out 2>&1
    touch $checkfil
  fi

done

done

exit

