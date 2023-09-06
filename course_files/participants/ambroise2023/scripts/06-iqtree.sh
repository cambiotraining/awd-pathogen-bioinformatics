#!/bin/bash

# create output directory
mkdir -p results/iqtree/

# FIX!!
# Run iqtree
iqtree -fconst FIX_CONSTANT_SITES -s FIX_INPUT_SNP_ALIGNMENT --prefix results/iqtree/ambroise -nt AUTO