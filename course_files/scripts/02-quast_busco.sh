#!/bin/bash

# gunzip results/wf-bacterial-genomes/new/*.fasta.gz

mkdir -p results/quast_busco/quast
mkdir -p results/quast_busco/busco

for file in results/wf-bacterial-genomes/new/barcode*.medaka.fasta
do 
    quast $file -o results/quast_busco/quast/$(basename $file medaka.fasta) --debug -g reference_genomes/vibriocholerae/GCA_017948285.1_ASM1794828v1_genomic.gff -r reference_genomes/vibriocholerae/GCA_017948285.1_ASM1794828v1_genomic.fna
    busco -m genome -i $file -f -o results/quast_busco/busco/$(basename $file medaka.fasta) --auto-lineage-prok
done

# Run multiqc for quast and busco results
cd results/quast_busco/
multiqc .