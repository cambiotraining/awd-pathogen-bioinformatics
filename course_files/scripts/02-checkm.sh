#!/bin/bash

# Setting up databases for checkM
#
# mkdir -p data/checkM_databases
# cd data/checkM_databases
# wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
# tar xfz checkm_data_2015_01_16.tar.gz
# checkm data setRoot $(pwd)
#
mkdir -p results/checkm

# Use -x to specify the format of input fasta files. By default it looks for .fna formats in the directory

checkm lineage_wf results/wf-bacterial-genomes/new/ results/checkm --tab_table -t 8 -x fasta --reduced_tree > results/checkm/sudan_samples_completeness.tsv