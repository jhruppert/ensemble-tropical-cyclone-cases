#!/bin/bash
#SBATCH -J preproc
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p skx-normal
#SBATCH -t 00:30:00 ##02:00:00
#SBATCH -o out_ens_prepoc.%j

# Took ~8 h to run all members for Haiyan

# This script prepares all ensemble members and runs pre-processing

storm='haiyan'
test_dir='haiyan' #'ctl'

# Directories
maindir="/scratch/06040/tg853394/wrfenkf"
ensdir="${maindir}/ensemble/${test_dir}"
wpsdir="${maindir}/WPS"
gefsdir="${maindir}/gefs/out"

source "$maindir/bashrc_wrf"

mkdir -p $ensdir
cd $ensdir

# Run pre-processing for each member

#for em in 0{1..9} {10..20}; do # Ensemble member
#for em in {18..20}; do # Ensemble member
for em in 07; do # Ensemble member

  dir="memb_${em}"
  mkdir -p $dir
  cd $dir

  echo "WORKING ON MEMBER: "${em}

  #LINK FILES

    mkdir -p wps
    cd wps

    #WPS files
    cp ${maindir}/namelists/namelist.wps.${storm} ./namelist.wps
    ln -sf ${wpsdir}/geo_em.d01.nc.${storm} geo_em.d01.nc
    ln -sf ${wpsdir}/geo_em.d02.nc.${storm} geo_em.d02.nc
    ln -sf ${wpsdir}/ungrib.exe .
    ln -sf ${wpsdir}/metgrid.exe .
    ln -sf ${wpsdir}/Vtable .
  
    #GEFS files
    #This links gens-a* and gens-b* files, which have different variables
    ${wpsdir}/link_grib.csh ${gefsdir}/gens-*_${em}.grb2

  #RUN WPS

    ungrib.exe > ungrib.out 2>&1
    metgrid.exe > metgrid.out 2>&1

  cd ..

  #SET UP WRF DIRECTORY

    mkdir -p wrf
    cd wrf

    ln -sf ../wps/met_em* .

  cd ../../

done

