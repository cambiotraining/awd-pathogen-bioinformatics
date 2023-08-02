#!/bin/bash

# FIX!!
# run the epi2me pipeline
nextflow run epi2me-labs/wf-bacterial-genomes \
  --sample_sheet FIXME \
  --fastq FIXME \
  --out_dir FIXME \
  --threads 8 \
  --reference_based_assembly True \
  --reference resources/reference_genome/GCF_937000105.1_CNRVC190243_genomic.fna \
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

