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
  --include genome,gff3 \
  --exclude-atypical \
  --released-after 01/01/2019

# unzip
unzip ncbi_dataset.zip

# convert files to panaroo
conda activate awd
wget https://raw.githubusercontent.com/gtonkinhill/panaroo/master/scripts/convert_refseq_to_prokka_gff.py

for genome in ncbi_dataset/data/*/*_genomic.fna
do
  fname=$(basename $genome .fna)
  dname=$(dirname $genome)
  
  # convert GFF
  python3 convert_refseq_to_prokka_gff.py \
    -g ${dname}/genomic.gff \
    -f $genome \
    -o resources/vibrio_genomes/${fname}.gff
    
  echo "Finished $fname"
done

# move FASTAs
mv ncbi_dataset/data/*/*.fna resources/vibrio_genomes/

# remove unnecessary files
rm -r ncbi_dataset ncbi_dataset.zip README.md convert_refseq_to_prokka_gff.py

# move genome to be used as reference 
# sequenced by Sanger from 2019 wave 3 O1 El Tor
mkdir resources/reference_genome/
cp resources/vibrio_genomes/GCF_937000105.1_CNRVC190243_genomic.fna resources/reference_genome


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


### Bakta database ###

# activate environment
conda activate assembly

mkdir -p resources/bakta_db
bakta_db download --output resources/bakta_db/ --type light