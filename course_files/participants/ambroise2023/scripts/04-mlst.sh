#!/bin/bash

# create output directory
mkdir results/mlst

# FIX!!
# run mlst
mlst --scheme vcholerae FIX_PATH_TO_FASTA_ASSEMBLY_FILES > results/mlst/mlst_typing.tsv

