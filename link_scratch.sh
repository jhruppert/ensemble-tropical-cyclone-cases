
srcdir=/ourdisk/hpc/radclouds/auto_archive_notyet/tape_2copies/tc_ens
outdir=/scratch/jamesrup/tc_ens

storm="haiyan"
# storm="maria"

itest="ctl"

for em in 0{1..9} 10; do # Ensemble member

  cd $outdir/$storm
  memdir="memb_${em}"
  mkdir -p $memdir
  cd $memdir
  mkdir -p $itest
  cd $itest

  srcfullpath=$srcdir/$storm/$memdir/$itest/
  ln -sf $srcfullpath/wrfinp* .
  ln -sf $srcfullpath/wrfbdy* .
  ln -sf $srcfullpath/wrflow* .
  ln -sf $srcfullpath/wrfrst* .

done