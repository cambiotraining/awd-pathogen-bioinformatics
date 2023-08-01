#!/bin/bash

# create output directory
mkdir results/mlst

# run mlst
mlst --scheme vcholerae results/wf-bacterial-genomes/assemblies/*.fasta > results/mlst/cholera_beirut_mlst.tsv

