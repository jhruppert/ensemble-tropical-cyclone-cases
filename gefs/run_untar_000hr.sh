#!/bin/bash

# Unpack GEFS tar balls

tardir="${ourdisk}/gefs"

header="gens_3_201709"

hours=( 00 06 12 18 )

#for dd in {14..20}; do # Day
for dd in 14; do # Day
for hh in "${hours[@]}"; do # Hour
#for em in 0{0..9} {10..20}; do # Ensemble member
for em in 01; do # Ensemble member

  echo "File: " "${tardir}/gens_2_201709${dd}${hh}_${em}.g2.tar"

  tar -xvf "${tardir}/gens_3_201709${dd}${hh}_${em}.g2.tar" \
    "gens-a_3_201709${dd}_${hh}00_000_${em}.grb2" \
    "gens-b_3_201709${dd}_${hh}00_000_${em}.grb2"

done
done
done

