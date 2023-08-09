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

We can assess this by using the [_CheckM2_](https://github.com/chklovski/CheckM2) software. 
This tool assesses the completeness of the assembled genomes based on other similar organisms in public databases, in addition to contamination scores. 
_CheckM2_ is mostly suited for prokaryotic species.
For other organisms, the [_BUSCO_](https://gitlab.com/ezlab/busco) software is a good alternative, as it supports all species and is also more stringent in determining completeness. 


## CheckM2

<!-- 
NOTE: this explanation was valid for CheckM1
Broadly, these are the steps of its analysis: 

- Split the sequences in our FASTA file into "bins", where each "bin" should represent the same organism. 
- Identify what species lineage each "bin" might represent, by comparing it against a database of known organisms. 
- Count how many of the known "core" genes from the identified species it can find in our own sequences - this is used to estimate the completeness of our assembly.  
- Count how many genes from other species it finds within each "bin" - this would indicate a contamination in our assembly.
-->

The software _CheckM2_ was specifically designed for working with metagenome-assembled genomes (MAGs). 
These are genomes created from a mixture of DNA from various species. 
_CheckM2_ has two main roles: it determines whether a given genome is complete and checks for signs of contamination in the genome. 
Contamination might occur when different organisms accidentally get combined in the assembly due to shared DNA sequences. 
Even though _CheckM2_ is intended for MAGs, it can also evaluate the completeness of genomes assembled from samples that aren't mixed (which is what we're dealing with).

This software employs machine learning models that were trained using many extensively annotated public sequences from [RefSeq](https://www.ncbi.nlm.nih.gov/refseq/). 
These models help _CheckM2_ estimate how complete and uncontaminated the provided genome assemblies are. 
In our case, we anticipate a minimal level of contamination, as confirmed by _Mash_. 
However, we're still uncertain about the completeness of our genomes.


### `checkm database`

As part of its analysis, _CheckM2_ also does a rapid gene annotation.
It does this by comparing our sequences to a database, using the super-fast local alignment software [_DIAMOND_](https://github.com/bbuchfink/diamond). 
This process enables _CheckM2_ to estimate the number of genes identified in our genomes, allowing us to make comparisons with the annotation of our organism's reference genome.

For the gene annotation step, _CheckM2_ requires a _DIAMOND_ database.
This can be downloaded with the following command (don't run this if you are attending our workshop, as we already did it for you):

```bash
checkm2 database --download --path resources/
```

This command will automatically download the database into a folder named `CheckM2_database` with a the database file inside it called `uniref100.KO.1.dmnd`.
We use this file in the next step.


### `checkm predict`

Once the database is available, running _CheckM2_ is done with the `checkm2 predict` command, exemplified in this shell script:

```bash
#!/bin/bash

# make output directory
mkdir results/checkm2

# run checkm
checkm2 predict \
  --input results/assemblies/*.fasta \
  --output-directory results/checkm2/ \
  --database_path resources/CheckM2_database/uniref100.KO.1.dmnd \
  --lowmem --threads 12
```

The options we used are: 

- `--input` - to specify the input files. Several files can be given as input, so we used the `*` wildcard to match all the FASTA files output by our [assembly workflow script](03-genome_assembly.md).
- `--output-directory` - the name of the output directory to store the results.
- `--database_path` - is the path to the database file we downloaded.
- `--lowmem` - in case you run this on a computer with low RAM memory (such as a laptop), this option will make sure the analysis runs successfully. 
- `--threads` - to use multiple CPUs for parallel processing, which you can adjust depending on how many CPUs you have available on your computer (you can check this with the command `nproc --all`).

The main output file from _CheckM2_ is a tab-delimited file called `quality_report.tsv`, which can be opened in a spreadsheet software such as _Excel_. 
Here is an example result (for brevity, we only show some columns of most interest): 

| Name             | Completeness | Contamination | Genome_Size | GC_Content | Total_Coding_Sequences |
| ---------------- | ------------ | ------------- | ----------- | ---------- | ---------------------- |
TODO

These columns indicate:

- **Name** - our sample name.
- **Completeness** - how complete our genome was inferred to be, based on the machine learning models used and the organisms present in the database.
- **Contamination** - the fraction of the genome assembly estimated to be contamination with other organisms (indicating our assembly isn't "pure"). 
- **Genome_Size** - how big the genome is estimated to be, based on other genomes present in the database. 
  One of the [recent _V. cholerae_ genomes](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) is 4.2 Mb in total (across both chromosomes), so these values make sense. 
- **GC_Content** - the percentage of G's and C's in the genome, which is relatively constant within a species. 
  The _V. cholerae_ GC content of the [reference genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) is 47.5%, so again these values make sense.
- **Total_Coding_Sequences** - the total number of coding sequences (genes) that were identified by _CheckM2_. 
  Once again, the [reference genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) used indicates 3,963 annotated genes, so the values obtained seem approximately correct (perhaps slightly over-estimated).

From this analysis, we can be confident that our genome assembly has high-quality and was successful, as we managed to recover most of the known genome of _V. cholerae_. 
We are therefore ready to proceed with downstream analysis, where we will further investigate how our samples relate to other _V. cholerae_ strains and whether we find evidence for antibiotic resistance. 


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
