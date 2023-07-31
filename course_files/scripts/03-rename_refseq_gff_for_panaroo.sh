#!/bin/bash

for i in resources/public_genomes/vcholerae/data/GCF_*/*.fna;
do
FNAME=$(basename ${i} .fna)
FPATH=$(dirname ${i})
#DNAME=${basename ${FNAME})
#mv ${i} ${FPATH}/${DNAME}.${FNAME}

mv ${FPATH}/${FNAME}_genomic.gff ${FPATH}/${FNAME}.gff

done

