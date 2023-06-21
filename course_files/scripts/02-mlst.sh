#!/bin/bash

mkdir results/mlst

for file in results/wf-bacterial-genomes/new/barcode*.medaka.fasta
do
    mlst $file > results/mlst/$(basename $file .medaka.fasta).tsv
done