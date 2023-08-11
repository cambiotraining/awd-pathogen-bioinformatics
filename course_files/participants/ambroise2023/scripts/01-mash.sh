#!/bin/bash

#### Settings ####
# change these variables if necessary

# directory with barcode folders from Guppy
fastq_dir="data/fastq_pass"

# output directory for results
outdir="results/mash"

# path to the Mash database file
mash_db="resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh"

#### End of settings ####


#### Analysis ####
# WARNING: be careful changing the code below

# exit upon any error
set -e

# create output directory
mkdir -p $outdir

# loop through each barcode
for filepath in $fastq_dir/*
do
    # get the barcode name
    barcode=$(basename $filepath)
    
    # print a message
    echo "Processing $barcode"
    
    # run mash command
    mash screen -w -p 8 $mash_db ${filepath}/*.fastq.gz | sort -n -r > ${outdir}/${barcode}_screen_sorted.tsv
done

# print a success message
echo "Finished! Results can be found in $outdir"