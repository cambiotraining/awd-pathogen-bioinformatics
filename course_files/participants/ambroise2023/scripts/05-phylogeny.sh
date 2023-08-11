#!/bin/bash

# create output directory
mkdir -p results/panaroo/

# Run panaroo
panaroo \
  --input results/assemblies/*.gff resources/vibrio_genomes/*.gff \
  --out_dir results/panaroo \
  --clean-mode strict \
  --alignment core \
  --core_threshold 0.98 \
  --remove-invalid-genes \
  --threads 8
