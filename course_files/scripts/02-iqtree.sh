#!/bin/bash

mkdir results/iqtree

iqtree -s results/panaroo/core_gene_alignment.aln -pre results/iqtree/awd -m GTR+F+I


