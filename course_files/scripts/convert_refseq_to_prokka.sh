#!/bin/bash

for gff_file in resources/public_genomes/vcholerae/data/GCF_*/*_genomic.gff;
do
  fname=$(basename $gff_file .gff) 
  dname=$(dirname $gff_file) 
  python3 scripts/convert_refseq_to_prokka_gff.py -g $gff_file -f $dname/$fname.fna -o data/panaroo_test/$fname.gff
done
