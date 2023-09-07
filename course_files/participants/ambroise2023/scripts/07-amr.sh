#!/bin/bash

# create output directory
mkdir results/funcscan

# FIX!!
# run the pipeline
nextflow run nf-core/funcscan -profile singularity \
  --max_memory 16.GB --max_cpus 8 \
  --input FIX_PATH_TO_SAMPLESHEET \
  --outdir FIX_PATH_TO_OUTPUT_DIRECTORY \
  --run_arg_screening \
  --arg_skip_deeparg