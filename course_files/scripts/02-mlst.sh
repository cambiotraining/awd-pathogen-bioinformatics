#!/bin/bash

#mkdir results/mlst

#for file in results/wf-bacterial-genomes/new/barcode*.medaka.fasta
#do
#    mlst $file > results/mlst/$(basename $file .medaka.fasta).tsv
#done

#cd results/mlst/
#cat * > results/mlst/cholera_beirut_mlst.tsv

mlst --scheme vcholerae results/wf-bacterial-genomes/new/*.fasta > results/mlst/cholera_beirut_mlst.tsv