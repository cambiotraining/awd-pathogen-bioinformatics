#!/bin/bash

for dir in data/fastq_pass/barcode{25..34}
do
    cp -r $dir data/fastq_pass/clean/
    zcat $dir/*.fastq.gz > data/fastq_pass/clean/$(basename $dir).fastq.gz
done

#cp -r data/fastq_pass/unclassified data/fastq_pass/clean/
