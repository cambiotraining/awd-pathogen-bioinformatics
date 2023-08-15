#!/bin/bash

# create output directory
mkdir -p results/panaroo/

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
