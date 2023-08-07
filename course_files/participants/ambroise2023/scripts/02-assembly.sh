#!/bin/bash

# mamba create --name assembly
# mamba install --name assembly flye rasusa medaka bakta
# note: I actually had to install medata with pip (within the conda environment)
# mamba activate assembly

#### Settings #####

# CSV file with two columns: sample,barcode
samplesheet="samplesheet.csv"
fastq_dir="data/fastq"

# output directory for results
outdir="results/assemblies"

# number of CPUs for parallel processing
threads="16"

# estimated genome size for flye '--genome-size' option
genome_size="4m"

# coverage to subsample reads to
coverage="100"

# medaka model matching your pore and basecalling mode
# should match the names shown on this page: 
# https://github.com/nanoporetech/medaka/tree/master/medaka/data
medaka_model="r941_min_hac_g507"

# path to the bakta database
bakta_db="resources/bakta_db/db-light/"

#### End of settings ####


#### Assembly pipeline ####
# WARNING: be careful changing the code below

# exit upon any error
set -e

# create output directories
mkdir -p "$outdir/01-rasusa/"
mkdir -p "$outdir/02-flye/"
mkdir -p "$outdir/03-medaka/"
mkdir -p "$outdir/04-bakta/"

# number of samples in samplesheet
nsamples=$(grep -c "" $samplesheet)

# iterate through samplesheet
for i in $(seq 2 $nsamples)
do
  # get sample name and barcode from samplesheet
  sample=$(head -n $i $samplesheet | tail -n 1 | cut -d "," -f 1)
  barcode=$(head -n $i $samplesheet | tail -n 1 | cut -d "," -f 2)
  echo "Starting sample '$sample' with barcode '$barcode'..."
  
  # subsample reads
  echo "  Subsampling reads with rasusa..."
  cat $fastq_dir/$barcode/*.fastq.gz > $outdir/01-rasusa/cat_${sample}.fastq.gz
  rasusa \
    --input "$outdir/01-rasusa/cat_${sample}.fastq.gz" \
    --coverage "$coverage" \
    --genome-size "$genome_size" \
    --output "$outdir/01-rasusa/$sample.fastq.gz" \
    > $outdir/01-rasusa/$sample.log 2>&1
  rm $outdir/01-rasusa/cat_${sample}.fastq.gz

  # flye assembly
  echo "  Assembling with flye..."
  flye \
    --nano-raw "$outdir/01-rasusa/$sample.fastq.gz" \
    --threads "$threads" \
    --out-dir "$outdir/02-flye/$sample/" \
    --asm-coverage "$coverage" \
    --genome-size "$genome_size" \
    > $outdir/02-flye/$sample.log 2>&1

  # polishing
  echo "  Polishing with medaka..."
  medaka_consensus -t "$threads" \
    -i "$outdir/01-rasusa/$sample.fastq.gz" \
    -d "$outdir/02-flye/$sample/assembly.fasta" \
    -o "$outdir/03-medaka/$sample" \
    -m $medaka_model \
    > $outdir/03-medaka/$sample.log 2>&1
  
  # annotate
  echo "  Annotating with bakta..."
  bakta \
    --db "$bakta_db" \
    --output "$outdir/04-bakta/$sample" \
    --threads "$threads" \
    --verbose \
    $outdir/03-medaka/$sample/consensus.fasta \
    > $outdir/04-bakta/$sample.log 2>&1
  
  # move final FASTA & GFF files to parent output directory
  mv $outdir/03-medaka/$sample/consensus.fasta $outdir/$sample.fasta
  mv $outdir/04-bakta/$sample/consensus.gff3 $outdir/$sample.gff3.gz
  # gzip -c $outdir/03-medaka/$sample/consensus.fasta > $outdir/$sample.fasta.gz
  # gzip -c $outdir/04-bakta/$sample/consensus.gff3 > $outdir/$sample.gff3.gz
  
  # print messages
  echo "  Finished assembly pipeline for '$sample'."
  echo "  Assembly file in: $outdir/$sample.fasta.gz"
  echo "  Annotation file in: $outdir/$sample.gff3.gz"

done
