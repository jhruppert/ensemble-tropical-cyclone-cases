#!/bin/bash

# Now running REAL and WRF fully separately using below switches

run_real=0
run_wrf=0
run_post_ncl=1
  post_depend=0 # for NCL only
#run_post_idl=0

storm="maria"
#storm="haiyan"
test_name='ctl'
#test_name='ncrf'
test_name='wsm6'

# WRF simulation details
  jobname="${storm}_${test_name}"
  queue='skx-normal'
  bigN=12
  smn=48
  # Restart
    irestart=0
#    timstr='04:00' # HH:MM

# NCL settings
  ncl_time="02:30"
  batch_ncl="batch_ncl.sh"
  dom="d02"
  # For single variable
#    ncl_time="00:30"
#    batch_ncl="batch_ncl_sing.sh"
# IDL settings
#  idl_time="00:05"
#  batch_idl="batch_idl.sh"

# Storm-specific settings
  if [[ ${storm} == 'maria' ]]; then

  # WRF simulation details
    test_t_stamp="2017-09-14_00:00:00"
    timstr='22:00' # HH:MM Job run time
      # Set to 22h for 7 d of Maria
  # NCL settings
    start_date="201709140000" # Start date for NCL
    ndays=6
  # Mechanism denial tests
    if [[ ${test_name} == 'ncrf' ]]; then
      test_t_stamp="2017-09-15_12:00:00"
      start_date="201709151200" # Start date for NCL
      ndays=4.5
    fi

  elif [[ ${storm} == 'haiyan' ]]; then

  # WRF simulation details
    test_t_stamp="2013-11-01_00:00:00"
    timstr='22:00' # HH:MM Job run time
      # 22h for 7 d of Haiyan
  # NCL settings
    start_date="201311010000" # Start date for NCL
    ndays=7
  # Mechanism denial tests
    if [[ ${test_name} == 'ncrf' ]]; then
      test_t_stamp="2013-11-02_12:00:00"
      start_date="201311021200" # Start date for NCL
      ndays=5.5
    fi

  fi # Storm ID

# Queue specifics
#if [ ${queue}="normal" ]; then
#  smn=68
#elif [ ${queue}="skx-normal" ]; then
#  smn=48
#fi

# Directories
  maindir="/scratch/06040/tg853394/wrfenkf"
  wkdir="/work2/06040/tg853394/stampede2/ens_tc"
  ensdir="${maindir}/ensemble/${storm}"
  wrfdir="${wkdir}/WRF"
#  wrfdebugdir="${maindir}/debug/WRF"

cd $ensdir

# All
#for em in 0{1..9} {10..20}; do # Ensemble member
# Special cases
for em in 01; do # Ensemble member
#for em in 01; do # Ensemble member

  dir="memb_${em}"
  cd $dir/wrf

if [ $run_real -eq 1 ]; then

  ln -sf ${wrfdir}/run/* .

  cat ${wkdir}/namelists/var_extra_output > var_extra_output
  rm namelist.input
  cp ${wkdir}/namelists/namelist.input.wrf.${storm}.ctl ./namelist.input

  # Create REAL batch script
cat > batch_real.job << EOF
#!/bin/bash
#SBATCH -J real-m${em}
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p skx-normal
#SBATCH -t 00:20:00
#SBATCH -o out_real.%j

cp ${wkdir}/bashrc_wrf .
source bashrc_wrf

#./real.exe
ibrun ./real.exe

EOF

  # Submit REAL job
  if [[ `grep SUCCESS rsl.error.0000 | wc -l` -eq 0 ]]; then
    sbatch batch_real.job > submit_real_out.txt
  fi

fi

#  JOBID=$(grep Submitted submit_real_out.txt | cut -d' ' -f 4)


if [ $run_wrf -eq 1 ]; then

  # Prep restart (only if running wrf.exe)
  if [ ${irestart} -eq 1 ]; then
    namelist="${wkdir}/namelists/namelist.input.wrf.${storm}.${test_name}.restart"
  else
    namelist="${wkdir}/namelists/namelist.input.wrf.${storm}.${test_name}"
  fi

  # Copy restart files from CTL if running mechanism denial test
  if [[ ${test_name} == 'ncrf' ]]; then
    ln -sf "../ctl/wrfrst_d01_${test_t_stamp}" .
    ln -sf "../ctl/wrfrst_d02_${test_t_stamp}" .
  fi

  # Create WRF batch script
cat > batch_wrf.job << EOF
#!/bin/bash
#SBATCH -J m${em}-${jobname}
#SBATCH -N ${bigN}
#SBATCH -n $((${smn}*${bigN}))
#SBATCH --ntasks-per-node ${smn}
#SBATCH -p ${queue}
#SBATCH -t ${timstr}:00
#SBATCH -o out_wrf.%j
### SBATCH --dependency=afterany:${JOBID}

source ${wkdir}/bashrc_wrf

cp ${namelist} ./namelist.input

# Modify nproc specs for WRF.exe
#sed -i '/nproc_x/c\ nproc_x = 34,' namelist.input
#sed -i '/nproc_y/c\ nproc_y = 20,' namelist.input

# Delete old text-out if necessary
rm rsl*
rm namelist.output

# Run WRF
ibrun ./wrf.exe

mkdir -p ../${test_name}
mkdir -p ../${test_name}/text_out
mkdir -p ../${test_name}/post
mkdir -p ../${test_name}/post/d01
mkdir -p ../${test_name}/post/d02
mv wrfout* wrfrst* ../${test_name}
mv rsl* namelist.out* out_wrf.* ../${test_name}/text_out
cp namelist.input ../${test_name}

  # Link first time step for mechanism denial tests for writing post-processed output
if [[ "${test_name}" == 'ncrf' ]]; then
  ln -sf ../ctl/wrfout_d0*_${test_t_stamp} ../${test_name}
fi

EOF
  
  # Submit WRF job
  #if [[ `grep SUCCESS rsl.error.0000 | wc -l` -eq 0 ]] then
#    sbatch batch_wrf.job > submit_wrf_out.txt
  #fi

fi

cd ..

if [ $run_post_ncl -eq 1 ]; then

  # Prep NCL post-proc
  cp -raf ${wkdir}/postproc .
  cd postproc
  if [ $post_depend -eq 1 ]; then
    # JOBID
    JOBID=$(grep Submitted ../wrf/submit_wrf_out.txt | cut -d' ' -f 4)
    sed -i "/dependency/c\#SBATCH --dependency=afterok:${JOBID}" ${batch_ncl}
  fi
  sed -i "/-J/c\#SBATCH -J m${em}-ncl" ${batch_ncl}
  sed -i "/runtime/c\#SBATCH -t ${ncl_time}:00" ${batch_ncl}
  sed -i '/dom=/c\dom="'${dom}'"' ${batch_ncl}
  sed -i "/Setdays/c\    nd=${ndays} ; Setdays" process_wrf.ncl
  sed -i '/Start time/c\    t0="'${start_date}'" ; Start time' process_wrf.ncl
  sed -i '/project directory/c\  dir="../'${test_name}'" ; project directory' process_wrf.ncl

  sbatch ${batch_ncl} > submit_ncl_out.txt

  cd ..

fi

#if [ $run_post_idl -eq 1 ]; then
#
#  # Prep IDL post-proc
#  cp -raf ${maindir}/postproc .
#  cd postproc
#  sed -i "/-J/c\#SBATCH -J m${em}-idl" ${batch_idl}
#  sed -i "/runtime/c\#SBATCH -t ${idl_time}:00" ${batch_idl}
#
#  sed -i "/member/c\ensmemb=${em}" idl_run.pro
#
#  sbatch ${batch_idl} > submit_idl_out.txt
#
#  cd ..
#
#fi

cd ..

done

exit
