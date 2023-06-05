#!/bin/bash

# Now running REAL and WRF fully separately using below switches

run_real=0
run_wrf=0
run_post_ncl=1
  post_depend=0 # for NCL only
#run_post_idl=0
  partition="radclouds"
#  partition="normal"

storm="haiyan"
# storm="maria"
#  Main tests:
#    ncrf36h for Haiyan, ncrf48h for Maria
#    crfon60h for Haiyan, crfon72h for Maria

# Haiyan
#test_name='ctl'
# test_name='ncrf36h'
#test_name='crfon60h'
test_name='STRATANVIL_ON'
test_name='STRATANVIL_OFF'
test_name='STRAT_OFF'

# Maria
#test_name='ctl'
# test_name='ncrf48h'
#test_name='crfon72h'

# WRF simulation details
  jobname="${storm}_${test_name}"
  queue='regular'
  bigN=12
  smn=36
  # Restart
    irestart=0
#    timstr='04:00' # HH:MM

# Queue specifics
#if [ ${queue}="normal" ]; then
#  smn=68
#elif [ ${queue}="skx-normal" ]; then
#  smn=48
#fi

# NCL settings
 ncl_time="06:00"
  # ncl_time="01:30" # For single variable
  batch_ncl="batch_ncl.sh"
  process_ncl="process_wrf.ncl"
  dom="d02"
  # Variable list
    varstr="{1..3} {8..23} 25 {27..29} 32 33 {36..51} 53" # Full list
    # varstr="24" # Single var
# IDL settings
#  idl_time="00:05"
#  batch_idl="batch_idl.sh"

###################################################

# Storm-specific settings
  if [[ ${storm} == 'maria' ]]; then

  # WRF simulation details
    test_t_stamp="2017-09-14_00:00:00"
    timstr='10:00' #'22:00' # HH:MM Job run time
      # Set to 22h for 7 d of Maria
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
      ndays=1.5
      restart_base='ctl'
test_t_stamp="2017-09-17_12:00:00"
restart_base=${test_name}
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
    timstr='22:00' # HH:MM Job run time
      # 22h for 7 d of Haiyan
  # NCL settings
    start_date="201311010000" # Start date for NCL
    ndays=4
  # Mechanism denial tests
    if [[ ${test_name} == 'ncrf36h' ]]; then
      timstr='05:00' # HH:MM Job run time
      test_t_stamp="2013-11-02_12:00:00"
      start_date="201311021200" # For NCL
      ndays=1.5 # For NCL
      restart_base='ctl'
test_t_stamp="2013-11-04_00:00:00"
restart_base=${test_name}
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
    elif [[ ${test_name} == 'STRATANVIL_ON' ]] || [[ ${test_name} == 'STRATANVIL_OFF' ]] || [[ ${test_name} == 'STRAT_OFF' ]]; then
      timstr='06:00' # HH:MM Job run time
      test_t_stamp="2013-11-02_12:00:00"
      start_date="201311021200" # For NCL
      ndays=2 # For NCL
      restart_base='ctl'
    fi

  fi # Storm ID

# Directories
  wkdir=${work}/ensemble-tropical-cyclone-cases
  # wrfdir=$wkdir/WRF
  wrfdir=$wkdir/wrf_$test_name
  # maindir=/ourdisk/hpc/radclouds/auto_archive_notyet/tape_2copies/tc_ens
  maindir=${scratch}/tc_ens
  ensdir=$maindir/$storm
  srcfile="bashrc_wrf_cys"
  srcpath=$wkdir/bashrcscripts/$srcfile

cd $ensdir

# All
#for em in 0{1..9} {10..20}; do # Ensemble member
for em in 0{1..9} 10; do # Ensemble member
# Special cases
# for em in 0{2..9} 10; do # Ensemble member
# for em in 01; do # Ensemble member

  memdir="$ensdir/memb_${em}"
  mkdir -p $memdir
  testdir=$memdir/$test_name
  mkdir -p $testdir
  mkdir -p $testdir/wrf
  cd $testdir/wrf

  echo "Running: $testdir"

if [ $run_real -eq 1 ]; then

  ln -sf ${wrfdir}/run/* .

  cat ${wkdir}/namelists/var_extra_output > var_extra_output
  rm -f namelist.input
  cp ${wkdir}/namelists/namelist.input.wrf.${storm}.ctl ./namelist.input

  # Create REAL batch script
cat > batch_real.job << EOF
#!/bin/bash
#SBATCH -J real-m${em}
#SBATCH -N 1
#SBATCH -n ${smn}
#SBATCH --exclusive
#SBATCH -p radclouds
#SBATCH -t 00:30:00
#SBATCH -o out_real.%j

cp $srcpath .
source $srcfile

#./real.exe
time mpirun ./real.exe

EOF

  # Submit REAL job
  if [[ `grep SUCCESS rsl.error.0000 | wc -l` -eq 0 ]]; then
    sbatch batch_real.job > submit_real_out.txt
  fi

fi

#  JOBID=$(grep Submitted submit_real_out.txt | cut -d' ' -f 4)


if [ $run_wrf -eq 1 ]; then

# Special case for data transfered from Expanse
  ln -sf ${wrfdir}/run/* .
  cat ${wkdir}/namelists/var_extra_output > var_extra_output
  rm -f namelist.input

  # Prep restart (only if running wrf.exe)
  if [ ${irestart} -eq 1 ]; then
    namelist=${wkdir}/namelists/namelist.input.wrf.${storm}.${test_name}.restart
  else
    namelist=${wkdir}/namelists/namelist.input.wrf.${storm}.${test_name}
  fi

  # Create WRF batch script
cat > batch_wrf_${test_name}.job << EOF
#!/bin/bash
#PBS -N m${em}-${jobname}
#PBS -A UOKL0041
#PBS -l walltime=${timstr}:00
#PBS -q regular
#PBS -j oe
#PBS -k eod
#PBS -l select=${bigN}:ncpus=${smn}:mpiprocs=${smn}:ompthreads=1

export TMPDIR=/glade/scratch/$USER/temp
mkdir -p $TMPDIR

# Copy restart files and BCs from CTL if running mechanism denial test
if [[ ${test_name} == *'crf'* ]] || [[ ${test_name} == *'STRAT'* ]]; then
  ln -sf "$memdir/${restart_base}/wrfrst_d01_${test_t_stamp}" .
  ln -sf "$memdir/${restart_base}/wrfrst_d02_${test_t_stamp}" .
  # mv "../wrfrst_d01_2013-11-03_12:00:00" .
  # mv "../wrfrst_d02_2013-11-03_12:00:00" .
  ln -sf "$memdir/ctl/wrfbdy_d01" .
  ln -sf "$memdir/ctl/wrflowinp_d01" .
  ln -sf "$memdir/ctl/wrflowinp_d02" .
fi

cp $srcpath .
source $srcfile

cp ${namelist} ./namelist.input

# Modify nproc specs for WRF.exe
sed -i '/nproc_x/c\ nproc_x = 24,' namelist.input
sed -i '/nproc_y/c\ nproc_y = 18,' namelist.input

# Delete old text-out if necessary
rm rsl*
rm namelist.output

# Run WRF
mpiexec_mpt ./wrf.exe

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
  # if [[ `grep SUCCESS rsl.error.0000 | wc -l` -eq 0 ]] then
    qsub batch_wrf_${test_name}.job > submit_wrf_out.txt
  # fi
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
#PBS -N m${em}-ncl
#PBS -A UOKL0041
#PBS -l walltime=${ncl_time}:00
#PBS -q regular
#PBS -j oe
#PBS -k eod
#PBS -l select=1:ncpus=${smn}:mpiprocs=${smn}:ompthreads=1

# module reset
module load ncl

dom="${dom}"

# Link first time step for mechanism denial tests for writing post-processed output
if [[ "${test_name}" == *'crf'* ]] || [[ "${test_name}" == *'STRAT'* ]]; then
  ln -sf $memdir/${restart_base}/wrfout_d0*_${test_t_stamp} ../
fi

# Modify NCL file
  sed -i "/Setdays/c\    nd=${ndays} ; Setdays" ${process_ncl}
  sed -i '/Start time/c\    t0="'${start_date}'" ; Start time' ${process_ncl}
  sed -i '/project directory/c\  dir=".." ; project directory' ${process_ncl}

del=6 # number of nodes per ncl call

EOF

  if [ $post_depend -eq 1 ]; then
    # JOBID
    JOBID=$(grep Submitted ../wrf/submit_wrf_out.txt | cut -d' ' -f 4)
    sed -i "/dependency/c\#SBATCH --dependency=afterok:${JOBID}" ${batch_ncl}
  fi

  cat loop.sh >> ${batch_ncl}

  # Insert var list
  sed -i "/loopvars/c\for v in ${varstr}; do" ${batch_ncl}

  # Replace SLURM_NTASKS with np
  sed -i "s/SLURM_NTASKS/${smn}/g" ${batch_ncl}

  qsub ${batch_ncl} > submit_ncl_out.txt
  # ./${batch_ncl} > ncl_out.txt 2>&1 &

fi

cd ../../

done

exit
