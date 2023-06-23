#!/bin/bash

mkdir results/mlst

mlst --scheme vcholerae results/wf-bacterial-genomes/new/*.fasta > results/mlst/cholera_beirut_mlst.tsv
