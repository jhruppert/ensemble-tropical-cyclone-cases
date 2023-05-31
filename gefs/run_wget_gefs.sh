#!/bin/bash

# Download GEFS data

wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282821/
wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282823/
wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282825/
wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282907/
wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282829/
wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282833/
wget -erobots=off -nv -m -np -nH --cut-dirs=3 --reject "index.html*" https://www.ncei.noaa.gov/pub/has/HAS012282835/

#mainpath="https://www.ncei.noaa.gov/pub/has/HAS012282823/"
#date="20170915"
#
#hours=( 00 06 12 18 )
#
#for hh in "${hours[@]}"; do # Hour of day
##for hh in 00; do # Hour of day
#for em in 0{0..9} {10..20}; do # Ensemble member
#
#  file_header="gens_2_${date}"
#  string="${mainpath}${file_header}${hh}_${em}.g2.tar"
#  wget $string
#
#  file_header="gens_3_${date}"
#  string="${mainpath}${file_header}${hh}_${em}.g2.tar"
#  wget $string
#
#done
#done

