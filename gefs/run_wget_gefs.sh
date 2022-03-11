#!/bin/bash

# Download GEFS data

mainpath="https://www1.ncdc.noaa.gov/pub/has/HAS012195115/"
file_header="gens_3_20131101"

#for hh in 0{0 6} 12 18; do # Hour of day
for hh in 00; do # Hour of day
for em in 0{0..9} {10..20}; do # Ensemble member

  string="${mainpath}${file_header}${hh}_${em}.g2.tar"

  wget $string

done
done

