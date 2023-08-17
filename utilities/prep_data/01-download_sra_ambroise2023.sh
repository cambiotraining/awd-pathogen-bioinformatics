#!/bin/bash

###################################
# Download data from Ambroise 2023
###################################
#
# download data from https://doi.org/10.1101/2023.02.17.23286076
# run this script from course_files/participants/ambroise2023
# software environment used:
#  mamba create --name sra
#  mamba install --name sra sra-tools seqtk
#
###################################

# activate environment
conda activate sra

# samplesheet - left some samples out to save compute time
echo "sample,barcode,platform,sra
CTMA_1402,barcode01,MinION,ERR10146532
CTMA_1421,barcode02,MinION,ERR10146551
CTMA_1427,barcode05,MinION,ERR10146520
CTMA_1432,barcode06,MinION,ERR10146521
CTMA_1473,barcode09,MinION,ERR10146531
" > samplesheet.csv

# these were the samples left out:
#  CTMA_1424,barcode03,MinION,ERR10146552
#  CTMA_1426,barcode04,MinION,ERR10149432
#  CTMA_1435,barcode07,MinION,ERR10146522
#  CTMA_1461,barcode08,MinION,ERR10146553

# samplesheet for funcscan
echo "sample,fasta
CTMA_1402,results/assemblies/CTMA_1402.fasta
CTMA_1421,results/assemblies/CTMA_1421.fasta
CTMA_1427,results/assemblies/CTMA_1427.fasta
CTMA_1432,results/assemblies/CTMA_1432.fasta
CTMA_1473,results/assemblies/CTMA_1473.fasta
" > samplesheet_funcscan.csv


# output directory
mkdir -p data/fastq_pass
cd data/fastq_pass

# fetch samples
for i in $(seq 2 10)
do
  # fetch SRA id
  sra=$(cat samplesheet_epi2me.csv | head -n $i | tail -n 1 | cut -d "," -f 4)
  alias=$(cat samplesheet_epi2me.csv | head -n $i | tail -n 1 | cut -d "," -f 2)
  barcode=$(cat samplesheet_epi2me.csv | head -n $i | tail -n 1 | cut -d "," -f 1)
  
  # message
  echo ">>>>> Processing: ${alias} (${sra})"
  
  # prefetch
  echo ">>>>> prefetch..."
  prefetch ${sra}

  # validate
  echo ">>>>> validate..."
  vdb-validate ${sra}

  # convert
  echo ">>>>> dump..."
  fasterq-dump ${sra}

  # gzip
  echo ">>>>> gzip..."
  gzip ${sra}.fastq
  
  # remove prefetch directory
  echo ">>>>> remove prefetch dir"
  rm -r ${sra}
  
  # move fastq to its own barcode dir
  mkdir $barcode
  mv ${sra}.fastq.gz $barcode
done