#!/bin/bash

###################################
# Download public data
###################################
#
# run this script from course_files/participants/ambroise2023
# software environment used:
#  mamba create --name ncbi_datasets
#  mamba install --name ncbi_datasets ncbi-datasets-cli
#
###################################

#### Vibrio genomes ####

# activate environment
# mamba create --name ncbi_datasets ncbi-datasets-cli
conda activate ncbi_datasets

# make directory
mkdir -p resources/vibrio_genomes/

# download complete genomes from 2019 onwards, see:
# https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=666
datasets download genome taxon 666 \
  --annotated \
  --assembly-level complete \
  --assembly-source 'RefSeq' \
  --include genome \
  --exclude-atypical \
  --released-after 01/01/2019

# unzip and tidy
unzip ncbi_dataset.zip
mv ncbi_dataset/data/*/*.fna resources/vibrio_genomes/
rm -r ncbi_dataset ncbi_dataset.zip README.md


### checkM database ###

# activate environment
conda activate awd

mkdir -p resources/checkm_db
wget -O checkm_db.tar.gz https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
tar -xzvf checkm_db.tar.gz -C resources/checkm_db/
rm checkm_db.tar.gz

# this command needs to be run by participants
checkm data setRoot $(pwd)/resources/checkm_db/


### MASH database ###

# activate environment
conda activate awd

mkdir -p resources/mash_db
wget -O resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh --no-check-certificate https://gembox.cbcb.umd.edu/mash/refseq.genomes%2Bplasmid.k21s1000.msh
