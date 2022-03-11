#!/bin/bash

# Unpack GEFS tar balls

header="gens_3_2013110100"

for em in 0{0..9} {10..20}; do # Ensemble member

  tar -xvf "../${header}_${em}.g2.tar"

done

