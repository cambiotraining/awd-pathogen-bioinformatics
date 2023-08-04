---
title: Assembly quality
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::


## Assessing assembly quality

There are various factors which may impact the quality of the final assembled genomes, from sample collection, to sequencing, to the bioinformatic analysis. 
For example biological and/or technical contamination of our samples may affect our ability to assemble the genomes as we will have a mixture of organisms, some of them not being of interest to us. 

Before we even did our assembly, we had already performed [content screening using _Mash_](02-read_content.md), directly from our sequencing reads.
This was useful to detect unexpected contaminations, since our samples were generated from cultured colonies, so we only expected to find _V. cholerae_. 
Now that we have performed our assembly, we can use further criteria to assess the quality of our assembled genomes. 
In particular we want to assess **genome completeness**, i.e. whether we managed to recover most of the genome or whether we have large fractions of the known _Vibrio_ genome missing.

We can assess this by using the _BUSCO_ and _CheckM2_ tools, which are part of the workflow illustrated in `@fig-TODO`. 
Both provide scores for each sample to assess the completeness of the assembled genomes, in addition to contamination scores. 
To have more confidence of the quality of our genomes we can run both of these tools. 
_CheckM2_ is more suited for prokaryotic species, while _BUSCO_ supports all species and is also more stringent in determining completeness. 


## CheckM2

<!-- 
NOTE: this explanation was valid for CheckM1
Broadly, these are the steps of its analysis: 

- Split the sequences in our FASTA file into "bins", where each "bin" should represent the same organism. 
- Identify what species lineage each "bin" might represent, by comparing it against a database of known organisms. 
- Count how many of the known "core" genes from the identified species it can find in our own sequences - this is used to estimate the completeness of our assembly.  
- Count how many genes from other species it finds within each "bin" - this would indicate a contamination in our assembly.
-->

The _CheckM2_ software was designed to work on metagenome-assembled genomes (MAGs), i.e. genomes assembled from an initial mixture of DNA. 
Two of its main tasks are to identify whether a given genome is complete, but also whether there is evidence for contamination in the genome (for example different organisms may unintentionally be assembled together due to a sequence similarity between them). 

_CheckM2_ uses machine learning models trained on millions of well-annotated public RefSeq sequences, which is uses to estimate completness and contamination of the provided genome assemblies. 
In our case, we should expect a low level of contamination (as [determined by _Mash_](02-read_content.md)), but we do not yet know whether our genomes are complete. 

As part of its analysis, _CheckM2_ also does a rapid gene annotation by comparing our sequences against a database, using a super-fast local alignment program called [DIAMOND](https://github.com/bbuchfink/diamond). 
This allows it to estimate how many genes were identified in our genomes, which we can compare with the annotation for the reference genome of our organism. 

For the rapid annotation step, _CheckM2_ requires us to download a DIAMOND database.
This can be done with the following command (don't run this if you are attending our workshop, as we already did it for you):

```bash
checkm2 database --download --path resources/
```

This command will automatically download the database into a folder named `CheckM2_database` with a the database file inside it called `uniref100.KO.1.dmnd`.
We use this file in the next step.

Once the database is available, running _CheckM2_ is done with the `checkm2 predict` command: 

```bash
#!/bin/bash

# make output directory
mkdir results/checkm2

# run checkm
checkm2 predict \
  --input results/wf-bacterial-genomes/*.fasta.gz \
  --output-directory results/checkm2/ \
  --database_path resources/CheckM2_database/uniref100.KO.1.dmnd \
  --lowmem --threads 12
```

The options we used are: 

- `--input` - to specify the input files. Several files can be given as input, so we used the `*` wildcard to match all the FASTA files output by the epi2me workflow.
- `--output-directory` - the name of the output directory to store the results.
- `--database_path` - is the path to the database file we downloaded.
- `--lowmem` - in case you run this on a computer with low RAM memory (such as a laptop), this option will make sure the analysis runs successfully. 
- `--threads` - to use multiple CPUs for parallel processing. You can adjust this depending on how many CPUs you have available on your computer (you can check this with the command `nproc --all`).

The main output file from _CheckM2_ is a tab-delimited file called `quality_report.tsv`, which can be opened in a spreadsheet software such as _Excel_. 
Here is an example result (for brevity, we only show some columns of most interest): 

| Name             | Completeness | Contamination | Genome_Size | GC_Content | Total_Coding_Sequences |
| ---------------- | ------------ | ------------- | ----------- | ---------- | ---------------------- |
| barcode25.medaka | 98.76        | 3.16          | 4083692     | 0.47       | 4151                   |
| barcode26.medaka | 99.87        | 1.17          | 4060133     | 0.47       | 3930                   |
| barcode27.medaka | 93.22        | 2.76          | 4058730     | 0.47       | 3937                   |
| barcode28.medaka | 97.91        | 1             | 4061692     | 0.47       | 3947                   |
| barcode29.medaka | 93.44        | 1.99          | 4062472     | 0.47       | 4344                   |
| barcode30.medaka | 91.35        | 0.92          | 4061145     | 0.47       | 4010                   |
| barcode31.medaka | 99.64        | 1.74          | 4037509     | 0.47       | 4031                   |
| barcode32.medaka | 91.47        | 3.75          | 4064429     | 0.47       | 4114                   |
| barcode33.medaka | 88.96        | 4.86          | 4085256     | 0.47       | 4301                   |
| barcode34.medaka | 99.93        | 1.34          | 4056819     | 0.47       | 4019                   |


These columns indicate:

- **Name** - our sample name.
- **Completeness** - how complete our genome was inferred to be, based on the machine learning models used and the organisms present in the database.
- **Contamination** - the fraction of the genome assembly estimated to be contamination with other organisms (indicating our assembly isn't "pure"). 
- **Genome_Size** - how big the genome is estimated to be, based on other genomes present in the database. The _V. cholerae_ [reference genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) we used is 4.2 Mb in total (across both chromosomes), so these values make sense. 
- **GC_Content** - the percentage of G's and C's in the genome, which is relatively constant within a species. The _V. cholerae_ GC content of the [reference genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) we used is 47.5%, so again these values make sense.
- **Total_Coding_Sequences** - this is the total number of coding sequences (genes) that were identified by _CheckM2_. Once again, the [reference genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) used indicates 3,963 annotated genes, so the values obtained seem approximately correct (perhaps slightly over-estimated).

From this analysis, we can be confident that our genome assembly has high-quality and was successful, as we managed to recover most of the known genome of _V. cholerae_. 
We are therefore ready to proceed with downstream analysis, where we will further investigate how our samples relate to other _V. cholerae_ strains and whether we find evidence for antibiotic resistance. 


## BUSCO

TODO


## Exercises 

:::{.callout-exercise}
#### Assembly QC

Run _CheckM2_ on your samples. 

TODO - improve description of exercise.

:::

## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
