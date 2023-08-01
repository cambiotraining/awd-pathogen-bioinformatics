#!/bin/bash

# create output directory
mkdir -p results/checkm

# FIX!!
# set directory to checkM database
checkm data setRoot FIX_PATH_TO_CHECKM_DB_FOLDER

# FIX!!
# run checkm to assign sequences to taxa
checkm lineage_wf --tab_table -t 8 -x fasta --reduced_tree FIX_PATH_TO_ASSEMBLIES_FASTA_DIR results/checkm/ > results/checkm/samples_completeness.tsv

