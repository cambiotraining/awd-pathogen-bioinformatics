#!/bin/bash

# create output directory
mkdir results/mlst

# run mlst
mlst --scheme vcholerae FIX_PATH_TO_FASTA_FILES > results/mlst/mlst_typing.tsv

