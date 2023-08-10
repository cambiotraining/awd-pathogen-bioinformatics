#!/bin/bash

## Change these accordingly
output_dir=results/iqtree/uae_denovo
input_dir=results/panaroo/uae_denovo

mkdir -p $output_dir

iqtree -s $input_dir/core_gene_alignment.aln -pre $output_dir/awd -m GTR+F+I
