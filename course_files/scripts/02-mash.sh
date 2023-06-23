#!/bin/bash

mkdir results/mash/

for file in data/fastq_pass/clean/*.fastq.gz
do
    mash screen reference_genomes/mash/refseq.genomes+plasmid.k21s1000.msh $file > results/mash/$(basename $file .fastq.gz)_screen.tab
    sort -gr results/mash/$(basename $file .fastq.gz)_screen.tab > results/mash/$(basename $file .fastq.gz)_screen_sorted.tsv
done
rm results/mash/*_screen.tab