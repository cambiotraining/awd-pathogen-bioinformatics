#!/bin/bash

# create output directory
mkdir -p results/iqtree/

# FIX!!
# Run iqtree
iqtree -s FIX_PATH_TO_CORE_GENE_ALIGNMENT --prefix results/iqtree/ambroise -m "GTR+F+I"