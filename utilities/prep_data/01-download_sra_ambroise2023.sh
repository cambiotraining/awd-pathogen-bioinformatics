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
echo "barcode,alias,platform,sra
barcode01,CTMA_1402,MinION,ERR10146532
barcode02,CTMA_1421,MinION,ERR10146551
barcode05,CTMA_1427,MinION,ERR10146520
barcode06,CTMA_1432,MinION,ERR10146521
barcode09,CTMA_1473,MinION,ERR10146531" > samplesheet_epi2me.csv

# these were the samples left out:
#  barcode03,CTMA_1424,MinION,ERR10146552
#  barcode04,CTMA_1426,MinION,ERR10149432
#  barcode07,CTMA_1435,MinION,ERR10146522
#  barcode08,CTMA_1461,MinION,ERR10146553

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