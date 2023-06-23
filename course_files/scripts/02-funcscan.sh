#!/bin/bash

mkdir results/funcscan

nextflow run nf-core/funcscan -profile docker -resume \
--input samplesheet.csv \
--outdir results/funcscan \
--run_arg_screening \
--arg_skip_deeparg