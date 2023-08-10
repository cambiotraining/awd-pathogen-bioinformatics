#!/bin/bash

## Create and activate environment for typing with phylogenetics
## Then install panaroo IQ_TREE, and Figtree

# mamba create -n typing
# mamba activate typing
# mamba install -c conda-forge -c bioconda -c defaults 'panaroo>=1.3', mlst, iqtree, figtree

## Change this settings accoordingly
panaroo_out="results/panaroo/uae_denovo"
assembly_results="results/assemblies/UAE"

mkdir -p $panaroo_out  

# Run panaroo
panaroo -i  $assembly_results/*.gff resources/public_genomes/vcholerae/data/GCF_*/*_genomic.gff -o $panaroo_out  --clean-mode strict -a core --core_threshold 0.98 -t 8 --remove-invalid-genes
