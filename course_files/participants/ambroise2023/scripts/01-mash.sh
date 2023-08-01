#!/bin/bash

# create output directory
mkdir results/mash

# FIX!!
# run mash on all FASTQ files simultaneously
mash screen -w -p 8 FIX_PATH_TO_MASH_DB_FILE data/fastq_pass/*/*.fastq.gz | sort -n -r > results/mash/screen.tsv

