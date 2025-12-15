#!/bin/bash

##################################
# Prepare files for participants
##################################
# this includes scripts, resources and FASTQ files
# 
# this script should be run from the repository's parent directory
#
# make sure to have run the other scripts in 
# utilities/prep_data


#### participant scripts ####

mkdir course_files/participants/ambroise2023/scripts/

# mash script
echo '#!/bin/bash

# create output directory
mkdir results/mash

# FIX!!
# run mash on all FASTQ files simultaneously
mash screen -w -p 8 FIX_PATH_TO_MASH_DB_FILE data/fastq_pass/*/*.fastq.gz | sort -n -r > results/mash/screen.tsv
' > course_files/participants/ambroise2023/scripts/01-mash.sh

# epi2me script
echo '#!/bin/bash

# FIX!!
# run the epi2me pipeline
nextflow run epi2me-labs/wf-bacterial-genomes \
  --sample_sheet FIXME \
  --fastq FIXME \
  --out_dir FIXME \
  --threads 8 \
  --reference_based_assembly True \
  --reference resources/vibrio_genomes/GCF_008369605.1_ASM836960v1_genomic.fna \
  --resfinder_version 4.3.2 \
  --mlst_version 2.23.0 \
  --isolates True \
  --medaka_consensus_model r941_min_fast_g507 \
  --medaka_variant_model r941_min_fast_variant_g507
  
# unzip the FASTA files (useful for downstream analysis)
gunzip results/wf-bacterial-genomes/*.fasta.gz

# move all the FASTA files to their own folder (useful for downstream analysis)
mkdir results/wf-bacterial-genomes/assemblies
mv results/wf-bacterial-genomes/*.fasta results/wf-bacterial-genomes/assemblies
' > course_files/participants/ambroise2023/scripts/02-epi2me.sh
  
# checkm script
echo '#!/bin/bash

# create output directory
mkdir -p results/checkm

# FIX!!
# set directory to checkM database
checkm data setRoot FIX_PATH_TO_CHECKM_DB_FOLDER

# FIX!!
# run checkm to assign sequences to taxa
checkm lineage_wf --tab_table -t 8 -x fasta --reduced_tree FIX_PATH_TO_ASSEMBLIES_FASTA_DIR results/checkm/ > results/checkm/samples_completeness.tsv
' > course_files/participants/ambroise2023/scripts/03-checkm.sh

# MLST script
echo '#!/bin/bash

# create output directory
mkdir results/mlst

# run mlst
mlst --scheme vcholerae results/wf-bacterial-genomes/assemblies/*.fasta > results/mlst/cholera_beirut_mlst.tsv
' > course_files/participants/ambroise2023/scripts/04-mlst.sh