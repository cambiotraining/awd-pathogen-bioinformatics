#!/bin/bash

# mkdir -p results/panaroo

panaroo -i data/panaroo_test/*.gff -o results/panaroo  --clean-mode strict -a core --core_threshold 0.98 -t 8 --remove-invalid-genes

