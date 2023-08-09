#!/bin/bash

# mamba create --name assembly
# mamba install --name assembly flye rasusa bakta
# mamba activate assembly
# pip install medaka

#### Settings #####

# CSV file with two columns: sample,barcode
samplesheet="samplesheet.csv"
fastq_dir="data/fastq_pass"

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

# exit upon any error and print useful message
trap 'echo -e "\tERROR: an error occurred while processing $sample.\n\tCheck the log file for the step that failed: $current_log"; exit' ERR

# create output directories
mkdir -p "$outdir/01-rasusa/"
mkdir -p "$outdir/02-flye/"
mkdir -p "$outdir/03-medaka/"
mkdir -p "$outdir/04-bakta/"

# number of rows in samplesheet
nsamples=$(grep -c "" $samplesheet)

# create a CSV for compiling assembly metrics
echo "sample,total_reads,downsampled_reads,assembly_length,fragments,n50,largest,coverage" >> $outdir/summary_metrics.csv

# iterate through samplesheet - first row assumed to be column headers
for i in $(seq 2 $nsamples)
do
  # get sample name and barcode from samplesheet
  sample=$(head -n $i $samplesheet | tail -n 1 | cut -d "," -f 1)
  barcode=$(head -n $i $samplesheet | tail -n 1 | cut -d "," -f 2)
  echo "Processing sample '$sample' with barcode '$barcode'"
  
  # concatenate reads
  echo -e "\t$(printf '%(%Y-%m-%d %H:%M:%S)T\n' -1)\t Concatenating reads..."
  cat $fastq_dir/$barcode/*.fastq.gz > $outdir/01-rasusa/cat_${sample}.fastq.gz
  
  # subsample reads
  echo -e "\t$(printf '%(%Y-%m-%d %H:%M:%S)T\n' -1)\t Subsampling reads with rasusa..."  
  current_log="$outdir/01-rasusa/$sample.log" # for error `trap`
  rasusa \
    --seed 20230808 \
    --input "$outdir/01-rasusa/cat_${sample}.fastq.gz" \
    --coverage "$coverage" \
    --genome-size "$genome_size" \
    --output "$outdir/01-rasusa/$sample.fastq.gz" \
    > $current_log 2>&1
  rm $outdir/01-rasusa/cat_${sample}.fastq.gz

  # flye assembly
  echo -e "\t$(printf '%(%Y-%m-%d %H:%M:%S)T\n' -1)\t Assembling with flye..."
  current_log="$outdir/02-flye/$sample.log" # for error `trap`
  flye \
    --nano-raw "$outdir/01-rasusa/$sample.fastq.gz" \
    --threads "$threads" \
    --out-dir "$outdir/02-flye/$sample/" \
    --asm-coverage "$coverage" \
    --genome-size "$genome_size" \
    > $current_log 2>&1

  # polishing
  echo -e "\t$(printf '%(%Y-%m-%d %H:%M:%S)T\n' -1)\t Polishing with medaka..."
  current_log="$outdir/03-medaka/$sample.log" # for error `trap`
  medaka_consensus -t "$threads" \
    -i "$outdir/01-rasusa/$sample.fastq.gz" \
    -d "$outdir/02-flye/$sample/assembly.fasta" \
    -o "$outdir/03-medaka/$sample" \
    -m $medaka_model \
    > $current_log 2>&1
  
  # annotate
  echo -e "\t$(printf '%(%Y-%m-%d %H:%M:%S)T\n' -1)\t Annotating with bakta..."
  current_log="$outdir/04-bakta/$sample.log" # for error `trap`
  bakta \
    --db "$bakta_db" \
    --output "$outdir/04-bakta/$sample" \
    --threads "$threads" \
    --verbose \
    $outdir/03-medaka/$sample/consensus.fasta \
    > $current_log 2>&1
  
  # move final FASTA & GFF files to parent output directory
  mv $outdir/03-medaka/$sample/consensus.fasta $outdir/$sample.fasta
  mv $outdir/04-bakta/$sample/consensus.gff3 $outdir/$sample.gff
  
  # compile summary statistics
  reads=$(grep "reads detected" $outdir/01-rasusa/$sample.log | awk '{ print $2 }')
  downsampled=$(grep "Keeping" $outdir/01-rasusa/$sample.log | awk '{ print $3 }')
  length=$(grep "Total length:" $outdir/02-flye/$sample/flye.log | awk '{ print $NF }')
  fragments=$(grep "Fragments:" $outdir/02-flye/$sample/flye.log | awk '{ print $NF }')
  n50=$(grep "Fragments N50:" $outdir/02-flye/$sample/flye.log | awk '{ print $NF }')
  largest=$(grep "Largest frg:" $outdir/02-flye/$sample/flye.log | awk '{ print $NF }')
  final_coverage=$(grep "Mean coverage:" $outdir/02-flye/$sample/flye.log | awk '{ print $NF }')
  
  echo "${sample},${reads},${downsampled},${length},${fragments},${n50},${largest},${final_coverage}" >> $outdir/summary_metrics.csv
  
  # print messages
  echo -e "\t$(printf '%(%Y-%m-%d %H:%M:%S)T\n' -1)\t Finished assembly pipeline for '$sample'."
  echo -e "\t                   \t Assembly file in: $outdir/$sample.fasta"
  echo -e "\t                   \t Annotation file in: $outdir/$sample.gff"

done

echo -e "\nAnalysis complete! Summary metrics in: $outdir/summary_metrics.csv"