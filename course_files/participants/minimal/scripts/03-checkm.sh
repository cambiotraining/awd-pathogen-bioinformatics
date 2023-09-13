#!/bin/bash

# make output directory
mkdir results/checkm2

# FIX!! 
# run checkm
checkm2 predict \
  --input FIX_PATH_TO_FASTA_FILES \
  --output-directory FIX_PATH_TO_OUTPUT_DIRECTORY \
  --database_path resources/CheckM2_database/uniref100.KO.1.dmnd \
  --lowmem --threads 8