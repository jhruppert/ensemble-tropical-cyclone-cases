#!/bin/bash

# Now running REAL and WRF fully separately using below switches

run_real=0
run_wrf=1
run_post_ncl=1
  post_depend=1 # for NCL only
#run_post_idl=0

#storm="maria"
storm="haiyan"
#test_name='ctl'
#test_name='ncrf36h'
#test_name='ncrf48h'
#test_name='crfon72h'
test_name='crfon60h'
#test_name='wsm6'

# WRF simulation details
  jobname="${storm}_${test_name}"
  queue='icx-normal'
  bigN=6
  smn=80 # tasks-per-node
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
  # Current setup takes ~12:30 for 4 days
  if [[ ${storm} == 'maria' ]]; then

  # WRF simulation details
    test_t_stamp="2017-09-14_00:00:00"
    timstr='15:00' # HH:MM Job run time
  # NCL settings
    start_date="201709140000" # Start date for NCL
    ndays=4
  # Mechanism denial tests
#    if [[ ${test_name} == 'ncrf' ]]; then
    if [[ ${test_name} == 'ncrf36h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2017-09-15_12:00:00"
      start_date="201709151200" # Start date for NCL
      ndays=1
      restart_base='ctl'
    elif [[ ${test_name} == 'ncrf48h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2017-09-16_00:00:00"
      start_date="201709160000" # Start date for NCL
      ndays=1
      restart_base='ctl'
    elif [[ ${test_name} == 'crfon72h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2017-09-17_00:00:00"
      start_date="201709170000" # Start date for NCL
      ndays=0.5
      restart_base='ncrf48h'
    fi

  elif [[ ${storm} == 'haiyan' ]]; then

  # WRF simulation details
    test_t_stamp="2013-11-01_00:00:00"
    timstr='15:00' # HH:MM Job run time
  # NCL settings
    start_date="201311010000" # Start date for NCL
    ndays=4
  # Mechanism denial tests
    if [[ ${test_name} == 'ncrf36h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2013-11-02_12:00:00"
      start_date="201311021200" # Start date for NCL
      ndays=1
      restart_base='ctl'
    elif [[ ${test_name} == 'ncrf48h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2013-11-03_00:00:00"
      start_date="201311030000" # Start date for NCL
      ndays=1
      restart_base='ctl'
    elif [[ ${test_name} == 'crfon60h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2013-11-03_12:00:00"
      start_date="201311031200" # Start date for NCL
      ndays=0.5
      restart_base='ncrf36h'
    fi

  fi # Storm ID

# Directories
  wkdir=${HOME}/ensemble-tropical-cyclone-cases
  wrfdir=$wkdir/WRF
  maindir=${SCRATCH}/tc_ens
  ensdir=$maindir/$storm
  srcfile=$wkdir/bashrc_wrf

cd $ensdir

# All
#for em in 0{1..9} {10..20}; do # Ensemble member
for em in 0{1..9} 10; do # Ensemble member
# Special cases
#for em in 09 10; do # Ensemble member

  memdir="$ensdir/memb_${em}"
  testdir=$memdir/$test_name
  mkdir -p $testdir
  mkdir -p $testdir/wrf
  cd $testdir/wrf

  echo "Running: $testdir"

#if [ $run_real -eq 1 ]; then
#
#  ln -sf ${wrfdir}/run/* .
#
#  cat ${wkdir}/namelists/var_extra_output > var_extra_output
#  rm namelist.input
#  cp ${wkdir}/namelists/namelist.input.wrf.${storm}.ctl ./namelist.input
#
#  # Create REAL batch script
#cat > batch_real.job << EOF
##!/bin/bash
##SBATCH --job-name=real-m${em}
##SBATCH --nodes=1
##SBATCH --ntasks-per-node=128
##SBATCH --partition=compute
##SBATCH -t 00:20:00 # runtime
##SBATCH --output=out_real.%j
##SBATCH --account=pen116
#
#cp $srcfile .
#source bashrc_wrf
#
##./real.exe
#ibrun ./real.exe
#
#EOF
#
#  # Submit REAL job
#  if [[ `grep SUCCESS rsl.error.0000 | wc -l` -eq 0 ]]; then
#    sbatch batch_real.job > submit_real_out.txt
#  fi
#
#fi

  JOBID=$(grep Submitted submit_real_out.txt | cut -d' ' -f 4)


if [ $run_wrf -eq 1 ]; then

# Special case for data transfered from Expanse
  ln -sf ${wrfdir}/run/* .
  cat ${wkdir}/namelists/var_extra_output > var_extra_output
  rm namelist.input

  # Prep restart (only if running wrf.exe)
  if [ ${irestart} -eq 1 ]; then
    namelist=${wkdir}/namelists/namelist.input.wrf.${storm}.${test_name}.restart
  else
    namelist=${wkdir}/namelists/namelist.input.wrf.${storm}.${test_name}
  fi

  # Create WRF batch script
cat > batch_wrf_${test_name}.job << EOF
#!/bin/bash
#SBATCH -J m${em}-${jobname}
#SBATCH -N ${bigN}
#SBATCH -n $((${smn}*${bigN}))
#SBATCH -p ${queue}
#SBATCH -t ${timstr}:00
#SBATCH -o out_wrf.%j
### SBATCH --dependency=afterany:${JOBID}

# Copy restart files and BCs from CTL if running mechanism denial test
if [[ ${test_name} == *'crf'* ]]; then
  ln -sf "$memdir/${restart_base}/wrfrst_d01_${test_t_stamp}" .
  ln -sf "$memdir/${restart_base}/wrfrst_d02_${test_t_stamp}" .
  ln -sf "$memdir/ctl/wrfbdy_d01" .
  ln -sf "$memdir/ctl/wrflowinp_d01" .
  ln -sf "$memdir/ctl/wrflowinp_d02" .
fi

cp $srcfile .
source bashrc_wrf

cp ${namelist} ./namelist.input

# Modify nproc specs for WRF.exe
sed -i '/nproc_x/c\ nproc_x = 30,' namelist.input
sed -i '/nproc_y/c\ nproc_y = 16,' namelist.input

# Delete old text-out if necessary
rm rsl*
rm namelist.output

# Run WRF
ibrun ./wrf.exe

mkdir -p ../text_out
mkdir -p ../post
mkdir -p ../post/d01
mkdir -p ../post/d02
mv wrfout* wrfrst* ../
#mv rsl* 
mv namelist.out* out_wrf.* ../text_out/
cp namelist.input ../text_out/
if [[ ${test_name} == 'ctl' ]]; then
  mv wrfinput* wrfbdy* wrflow* ../
fi

EOF
  
  # Submit WRF job
  #if [[ `grep SUCCESS rsl.error.0000 | wc -l` -eq 0 ]] then
    sbatch batch_wrf_${test_name}.job > submit_wrf_out.txt
  #fi
  tail submit_wrf_out.txt

fi

cd ..

if [ $run_post_ncl -eq 1 ]; then

  # Prep NCL post-proc
  cp -raf ${wkdir}/postproc .
  cd postproc

  # Create NCL batch script
cat > ${batch_ncl} << EOF
#!/bin/bash
#SBATCH -J m${em}-ncl
#SBATCH -N 4
#SBATCH -n 320
#SBATCH -p icx-normal
#SBATCH -t ${ncl_time}:00
#SBATCH -o out_ncl.%j
## SBATCH --dependency=afterany:

source ../wrf/bashrc_wrf

dom="${dom}"

# Link first time step for mechanism denial tests for writing post-processed output
if [[ "${test_name}" == *'crf'* ]]; then
  ln -sf $memdir/${restart_base}/wrfout_d0*_${test_t_stamp} ../
fi

# Modify process_wrf.ncl
  sed -i "/Setdays/c\    nd=${ndays} ; Setdays" process_wrf.ncl
  sed -i '/Start time/c\    t0="'${start_date}'" ; Start time' process_wrf.ncl
  sed -i '/project directory/c\  dir=".." ; project directory' process_wrf.ncl

del=12 # number of nodes per ncl call

EOF

  if [ $post_depend -eq 1 ]; then
    # JOBID
    JOBID=$(grep Submitted ../wrf/submit_wrf_out.txt | cut -d' ' -f 4)
    sed -i "/dependency/c\#SBATCH --dependency=afterok:${JOBID}" ${batch_ncl}
  fi

  cat loop.sh >> ${batch_ncl}

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

cd ../../

done

exit
