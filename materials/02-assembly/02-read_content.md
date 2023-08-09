---
title: Assessing read content
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::

## Read content

As detailed in the [previous section](01-preparing_data.md), our example data was obtained from _Vibrio cholerae_ colonies from plate cultures. 
Therefore, we expect our sequencing reads to contain only _V. cholerae_ sequences and nothing else. 
If we had used a metagenomic approach, we would have expected other organisms to also be contained in our reads. 

Therefore, before attempting to assemble genomes from our samples, it is a good idea to **screen which organisms can be detected in our sequencing reads**. 
For plate-based samples like ours, this is a good quality check for our samples, as we can confirm that they contain _V. cholerae_ only and are not contaminated with other organisms.
For metagenomic samples, where we expect a mixture of organisms (including Human), we can get an idea of whether _V. cholerae_ is present in the sample and at what fraction.

To screen our reads for known bacterial species we will use the software [_Mash_](https://doi.org/10.1186/s13059-016-0997-x), which implements an algorithm for fast screening raw sequencing reads against a database.


## Mash database

Before screening our reads, we must first download the most up-to-date database used by Mash.
There are several pre-compiled databases available from the [Mash website](https://mash.readthedocs.io/en/latest/data.html).
We will use one that includes both bacterial genomes and plasmids (see [example tutorial](https://mash.readthedocs.io/en/latest/tutorials.html#querying-read-sets-against-an-existing-refseq-sketch)). 

If you are attending our workshop, we have already downloaded these files for you, but here are the commands we used to achieve this: 

```bash
# create subdirectory for mash database
mkdir -p resources/mash_db 

# download the database file
wget -O resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh --no-check-certificate https://gembox.cbcb.umd.edu/mash/refseq.genomes%2Bplasmid.k21s1000.msh
```

As you can see, because this is a public resource, we saved it in our `resources` folder. 


## Mash screen

The main step of our analysis can be run using the `mash screen` command. 
This command takes the Mash database and checks how well its sequences are contained in our reads, for each organism.
If our sequencing reads cover the entire genome of _V. cholerae_, then we expect both a **high sequence identity** and a **high percentage of shared sequences** with that organism. 

To start our analysis, we first create a folder for our output: 

```bash
mkdir results/mash
```

To run the analysis on a single sample, we can run the following command: 

```bash
mash screen -w -p 8 resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh data/fastq_pass/barcode25/*.fastq.gz | sort -n -r > results/mash/barcode25_screen.tsv
```

There are several things to note about this command: 

- We use the option `-w`, which according to the help (`mash screen -h`) refers to the "winner-take-all strategy", which removes much of the redundancy in the results to make interpretation of the results easier.
- We use the `-p` option to use more CPU cores, to speed the computation by running the analysis in parallel. 
- We use the `*` wildcard to match all the FASTQ files within the `fastq_pass/barcode25` data folder (ONT often outputs multiple FASTQ files per barcode).
- We pipe the output of mash to the `sort` command to order the results in descending order of sequence identity against the Mash database. This will make sure that we get the hits with the highest identity at the top of the file.
- The output from Mash is a tab-delimited file, so we save our output with `.tsv` extension to indicate this.

We can either open this file in a spreadsheet program (such as _Excel_), or use the program `less` to open it directly in the terminal:

```bash
less results/mash/barcode25_screen.tsv
```

```
1       1000/1000       425     0       GCF_000279455.1_ASM27945v1_genomic.fna.gz       [25 seqs] NZ_ALDQ01000001.1 Vibrio cholerae HC-46A1 vcoHC46A1.contig.0, w>
0.999857        997/1000        428     0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.99655 930/1000        811     0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence
0.978312        631/1000        379     0       ref|NC_010072.1|        Yersinia pestis plasmid pIP1203, aph(3'')-Ib gene and aph(6)-Id gene for aminoglycoside p>
0.959532        420/1000        553     0       ref|NC_008690.1|        Vibrio sp. TC68 plasmid pTC68, complete sequence
0.932215        229/1000        366     0       ref|NC_005862.1|        Salmonella enterica enterica sv Choleraesuis plasmid cryptic, complete sequence
0.931825        227/1000        478     0       ref|NC_017329.1|        Shigella flexneri 2002017 plasmid pSFxv_3, complete sequence
0.922791        185/1000        402     0       ref|NC_011378.1|        Pasteurella multocida plasmid pCCK1900, complete sequence
```

The output file contains one row for each organism (or plasmid) from the Mash database that was found in our sequencing reads. 
The columns in the output file are in the following order:

- **identity** - the percentage of sequence similarity between the database and our reads.
- **shared-hashes** - a score referring to how many sequences in the database for that organism were matched to our reads.
- **median-multiplicity** - the average number of times each database sequence is found in our reads (this is a very rough proxy for genome coverage).
- **p-value** - a statistical measure of the significance of the distance between the sequences in the database and our own sequencing reads. Low values (close to zero) indicate that it would be very unlikely to observe such similarity by chance alone.
- **query-id** - the name of the sequence in the Mash database that was used to report these matches.
- **query-comment** - the description of the query sequence.

From the results above, we can see that our reads appear to be clearly related to _V. cholerae_. 
The second hit is "Vibrio phage CTX", which refers to the phage encoding the cholera toxin, [CTXφ](https://en.wikipedia.org/wiki/CTX%CF%86_bacteriophage).

This analysis initially answers two critical questions with regards to cholera genomic surveillance, which are:

- **Is this V.cholerae?** Yes, it appears that our samples contain _V. cholerae_ sequences.
- **Is this a pathogenic strain?** Yes, it appears that our samples belong to a pathogenic serogroup, because they contain the CTXφ prophage.

The second question will be confirmed during downstream analyses.


## Screening multiple samples

In the above analysis, we only screened one sample. 
To analyse the other samples we could re-run the command, replacing the barcode number each time. 
However, if we have dozens of samples, this can become very tedious and prone to error, as it requires a lot of copy/paste. 
Therefore, we could automate the analysis for each barcode by using a _for loop_, which is demonstrated in the code below. 

```bash
#!/bin/bash

# create output directory
mkdir results/mash/

# loop through each barcode
for filepath in data/fastq_pass/*
do
    # get the barcode name
    barcode=$(basename $filepath)
    
    # run mash command
    mash screen -w -p 8 resources/mash_database/refseq.genomes+plasmid.k21s1000.msh ${filepath}/*.fastq.gz | sort -n -r > results/mash/${barcode}_screen_sorted.tsv
done
```

The result in this case will be individual TSV files for each barcode, which we could open individually to see what the top hits for each of them were. 
You could also use the `head` command to look at the top few lines of each file in one go, as exemplified here: 

```bash
# look at the top 3 lines of every screen file
head -n 3 results/mash/barcode*.tsv
```

```
==> results/mash/barcode25.tsv <==
0.999473        989/1000        12      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.999135        982/1000        11      0       GCF_000348385.2_ASM34838v2_genomic.fna.gz       [86 seqs] NZ_KB662481.1 Vibrio cholerae O1 str. NHCC-004A genomic scaffold vcoNHCC004A.contig.0, whole genome sh>
0.994092        883/1000        13      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence

==> results/mash/barcode26.tsv <==
0.99957 991/1000        46      0       GCF_001187225.1_ASM118722v1_genomic.fna.gz      [97 seqs] NZ_LGNX01000001.1 Vibrio cholerae O1 strain NHCC-079 Contig1, whole genome shotgun sequence [...]
0.999377        987/1000        36      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.994519        891/1000        63      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence

==> results/mash/barcode27.tsv <==
0.999522        990/1000        44      0       GCF_000348385.2_ASM34838v2_genomic.fna.gz       [86 seqs] NZ_KB662481.1 Vibrio cholerae O1 str. NHCC-004A genomic scaffold vcoNHCC004A.contig.0, whole genome sh>
0.999377        987/1000        36      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.995206        904/1000        68      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence
```

We can see that the results for individual barcodes (here we show 3 barcodes as an example) are similar to each other, which we expect as all these samples come from the same outbreak event and so should be related to each other.


## Exercises

:::{.callout-exercise}
#### Mash screening

Run the _Mash_ analysis on one of the barcodes.

TODO: finish exercise description
:::

:::{.callout-exercise}
#### Screening by barcode
{{< level 3 >}}

In the previous exercise the analysis was for a single sample. 
Use a _for loop_ to run the analysis for each barcode individually, using a script we provide. 

TODO: finish exercise description
:::

## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
