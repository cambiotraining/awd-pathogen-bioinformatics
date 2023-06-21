#!/bin/bash


nextflow run epi2me-labs/wf-bacterial-genomes -resume \
--sample_sheet sample_sheet.csv \
--fastq data/fastq_pass/clean \
--reference 'reference_genomes/vibriocholerae/GCA_017948285.1_ASM1794828v1_genomic.fna' \
--threads 4 \
--out_dir 'results/wf-bacterial-genomes/new' \
--reference_based_assembly True \
--isolates True \
--species 'other' 


mv output results/wf-bacterial-genomes/new/