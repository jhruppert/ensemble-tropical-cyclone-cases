#!/bin/bash
#SBATCH -J tar_m
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -o out_tar.%j

# Copy files to archive/transfer them via Globus

storm="maria"
#storm="haiyan"

tcdir="/stornext/ranch_01/ranch/projects/TG-ATM090042/Ruppert/tc_output_ensemb"

#for em in 0{1..9} {10..20}; do # Ensemble member
#for em in {17..20}; do # Ensemble member
for em in 20; do # Ensemble member

  tar cf "tarballs/memb_${em}_${storm}.tar" "${storm}/memb_${em}/" > tar_memb${em}_${storm}.out 2>&1
#  tar cf - "${storm}/memb_${em}/" | ssh $ARCHIVER "cat > ${tcdir}/${storm}/memb_${em}_${storm}.tar"

done

exit

