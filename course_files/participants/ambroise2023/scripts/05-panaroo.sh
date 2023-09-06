#!/bin/bash

# create output directory
mkdir -p results/panaroo/
mkdir -p results/snp-sites/

# FIX!!
# Run panaroo
panaroo \
  --input FIX_PATH_TO_INPUT_FILES \
  --out_dir FIX_OUTPUT_DIRECTORY \
  --clean-mode strict \
  --alignment core \
  --core_threshold 0.98 \
  --remove-invalid-genes \
  --threads 8

# extract variable sites
snp-sites results/panaroo/core_gene_alignment.aln > results/snp-sites/core_gene_alignment_snps.aln

# count invariant sites
snp-sites -C results/panaroo/core_gene_alignment.aln > results/snp-sites/constant_sites.txt