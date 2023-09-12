---
title: Assessing read content
---

::: {.callout-tip}
#### Learning Objectives

After this section you should be able to:

- Describe why assessing the species content of your reads is a useful first step in the analysis.
- Explain how the read content is assessed, in particular by the software _Mash_.
- Apply the _Mash_ software to identify the species content of your sequencing reads.
- Discuss the results of the content screening and when they might indicate a contamination or unexpected organism is present in the samples.
:::

## Read content

As detailed in the [previous section](01-preparing_data.md), our example data was obtained from _Vibrio cholerae_ colonies from plate cultures. 
Therefore, we expect our sequencing reads to contain only _V. cholerae_ sequences and nothing else. 
If we had used a metagenomic approach, we would have expected other organisms to also be contained in our reads. 

Therefore, before attempting to assemble genomes from our samples, it is a good idea to **screen which species can be detected in our sequencing reads**. 
For plate-based samples like ours, this is a good quality check for our samples, as we can confirm that they contain _V. cholerae_ only and are not contaminated with other organisms.
For metagenomic samples, where we expect a mixture of organisms (including Human), we can get an idea of whether _V. cholerae_ is present in the sample and at what fraction.

Generally speaking, assessing read content can be done by comparing our sequencing reads against a database of sequences from known organisms.
Two popular software options for this task are:

- [_Kraken2_](https://ccb.jhu.edu/software/kraken2/), which categorises each sequencing read to the highest possible taxonomic level. 
  _Kraken2_ is commonly used in metagenomic analysis, especially when combined with [_Braken_](https://ccb.jhu.edu/software/bracken/), which allows estimating species abundance in a mixed sample.
  However, it can be computationally intensive.
- [_Mash_](https://mash.readthedocs.io/en/latest/) is a faster alternative for assessing species content in reads. 
  It doesn't assign a taxonomy to individual reads but reports the sample's content based on matches with its database sequences. 
  The drawback is that it doesn't provide precise species abundance estimation.

For our case study, which uses cultured samples, we choose to use _Mash_ for its speed. 


## Mash

To screen our reads for known bacterial species we will use the software [_Mash_](https://doi.org/10.1186/s13059-016-0997-x), which implements an algorithm for fast screening raw sequencing reads against a database.
The _Mash_ software, primarily designed for metagenomic samples with multiple species, can also be applied to culture-based samples to confirm the presence of the expected organism and detect potential contaminants.
_Mash_ is known for its speed in assessing the species content of sequencing reads without requiring genome assembly. 

![Schematic view of the _Mash_ algorithm approach. In this example, the 4th species is likely to be what’s contained in our sample, as there were matches to all its sub-sequences (shown as coloured bars). Source: adapted from Fig. 2 in [Ondov et al. 2019](https://doi.org/10.1186/s13059-019-1841-x).](images/mash.png){#fig-mash}

To run _Mash_, a pre-built database file is needed, readily available online from the developers. 
This database is constructed from bacterial organisms found in public databases like NCBI's RefSeq. 
For efficiency, the developers break down each reference sequence into smaller sub-sequences, as shown in @fig-mash. 
Occasionally, different organisms may share similar sub-sequences, but _Mash_ can differentiate them by examining other sub-sequences. 
When your reads are matched against these sub-sequences, _Mash_ counts the hits for each species. 
The species with the most matches in the database is likely the main species in your sample. 
If you have multiple organisms, as in a metagenomic sample, different species may show a high fraction of matched sub-sequences.


### Mash database

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


### Mash screen

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
less -S results/mash/barcode25_screen.tsv
```

```
0.99957   991/1000  46  0  GCF_001187225.1_ASM118722v1_genomic.fna.gz     [97 seqs] NZ_LGNX01000001.1 Vibrio cholerae O1 strain NHCC-079 Contig1, whole genome shotgun sequence [...]
0.999377  987/1000  36  0  GCF_000893195.1_ViralProj63437_genomic.fna.gz  NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.994519  891/1000  63  0  ref|NC_004982.1|                               Vibrio cholerae strain O395P plasmid pTLC, complete sequence
0.993445  871/1000  90  0  ref|NC_008613.1|                               Photobacterium damselae subsp. piscicida plasmid pP91278, complete sequence
0.967069  495/1000  74  0  ref|NZ_CP013143.1|                             Alcaligenes faecalis strain ZD02 plasmid pZD02, complete sequence
0.962791  451/1000  83  0  ref|NZ_CP007487.1|                             Salmonella enterica subsp. enterica strain SA972816 plasmid p972816 sequence
0.959749  422/1000  96  0  ref|NZ_CP007486.1|                             Salmonella enterica subsp. enterica strain SA972816 plasmid p972816 sequence
0.952766  362/1000  96  0  ref|NZ_CP007485.1|                             Salmonella enterica subsp. enterica strain SA972816 plasmid p972816 sequence
0.952135  357/1000  99  0  ref|NC_011511.1|                               Klebsiella pneumoniae plasmid p169, complete sequence
0.95188   355/1000  32  0  ref|NC_017172.1|                               Acinetobacter baumannii MDR-ZJ06 plasmid pMDR-ZJ06, complete sequence
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
    
    # print a message
    echo "Processing ${barcode}"
    
    # run mash command
    mash screen -w -p 8 resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh ${filepath}/*.fastq.gz | sort -n -r > results/mash/${barcode}_screen_sorted.tsv
done
```

The result in this case will be individual TSV files for each barcode, which we could open individually to see what the top hits for each of them were. 
You could also use the `head` command to look at the top few lines of each file in one go, as exemplified here: 

```bash
# look at the top 3 lines of every screen file
head -n 3 results/mash/barcode*.tsv
```

```
==> results/mash/barcode25_screen_sorted.tsv <==
0.999473        989/1000        12      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.999135        982/1000        11      0       GCF_000348385.2_ASM34838v2_genomic.fna.gz       [86 seqs] NZ_KB662481.1 Vibrio cholerae O1 str. NHCC-004A genomic scaffold vcoNHCC004A.contig.0, whole genome shotgun sequence [...]
0.994092        883/1000        13      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence

==> results/mash/barcode26_screen_sorted.tsv <==
0.99957 991/1000        46      0       GCF_001187225.1_ASM118722v1_genomic.fna.gz      [97 seqs] NZ_LGNX01000001.1 Vibrio cholerae O1 strain NHCC-079 Contig1, whole genome shotgun sequence [...]
0.999377        987/1000        36      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.994519        891/1000        63      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence

==> results/mash/barcode27_screen_sorted.tsv <==
0.999522        990/1000        44      0       GCF_000348385.2_ASM34838v2_genomic.fna.gz       [86 seqs] NZ_KB662481.1 Vibrio cholerae O1 str. NHCC-004A genomic scaffold vcoNHCC004A.contig.0, whole genome shotgun sequence [...]
0.999377        987/1000        36      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.995206        904/1000        68      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence

... some output ommitted to save space ...
```

We can see that the results for individual barcodes (here we show 3 barcodes as an example) are similar to each other, which we expect as all these samples come from the same outbreak event and so should be related to each other.


## Exercises

<i class="fa-solid fa-triangle-exclamation" style="color: #1e3050;"></i> 
For these exercises, you can either use the dataset we provide in [**Data & Setup**](../../setup.md), or your own data. 

:::{.callout-exercise}
#### Mash screening

Screen the sequencing reads for known organisms, by running _Mash_ on one of the barcodes of your choice.

- Make sure you start from your analysis directory: `cd ~/Documents/YOUR_FOLDER`.
- Create an output directory for the results called `results/mash`.
- Activate the software environment: `conda activate mash`.
- Run the `mash screen` command on a barcode of your choice:
  - Save the results to a file called `results/mash/barcodeXX_screen.tsv` (replace "XX" with the barcode number you are analysing).
  - The _Mash_ database is already available at `resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh`

The command might take some time to run (maybe 10 minutes). 
Once it completes, examine the output file to investigate if your reads contained the organism you were expecting.

:::{.callout-hint collapse=true}
- Remember that to create a directory from the command line you can use the `mkdir` command.
- The general command to run `mash` is:  
  `mash screen -w -p 8  PATH_TO_DB_FILE  PATH_TO_INPUT_FASTQS  |  sort -n -r >  OUTPUT_FILE`
:::

:::{.callout-answer collapse=true}

These solutions are for the "Ambroise 2023" dataset.
We first made sure that were were on that folder: 

```bash
cd ~/Documents/ambroise2023
```

We then created an output directory and activated our software environment:

```bash
mkdir results/mash
mamba activate mash
```

We could confirm the software environment was active as our terminal showed `(mash)` at the start.

Finally, we ran the `mash screen` command for "barcode01": 

```bash
mash screen -w -p 8  resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh  data/fastq_pass/barcode01/*.fastq.gz  |  sort -n -r >  results/mash/barcode01_screen.tsv
```

The output file is in tab-delimited (TSV) format. We can open this file in _Excel_, or directly from the command line:

```bash
# look at the top 3 lines of the file
head -n 3 results/mash/barcode01_screen.tsv
```

```
1         1000/1000  42  0  GCF_000279245.1_ASM27924v1_genomic.fna.gz      [23 seqs] NZ_ALDE01000001.1 Vibrio cholerae CP1041(14) vcoCP1041.contig.0, whole genome shotgun sequence [...]
0.999618  992/1000   39  0  GCF_000893195.1_ViralProj63437_genomic.fna.gz  NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.995779  915/1000   73  0  ref|NC_004982.1|                               Vibrio cholerae strain O395P plasmid pTLC, complete sequence
```

Indeed, we can confirm that our reads contain _Vibrio cholerae_ sequences. 
The second hit is to the CTX phage, which indicates this is a pathogenic strain. 
:::
:::

:::{.callout-exercise}
#### Screening multiple samples

In the previous exercise, you ran the analysis for a single sample. 
However running the analysis individually is impractical when you have many samples/barcodes to process. 

In the folder `scripts` (within your analysis directory) you will find a script named `01-mash.sh`. 
This script contains the code to use a programatic technique known as a _for loop_ to automatically repeat the analysis for each barcode. 

- Open the script and examine its code to see if you can understand what it is doing. 
  The script is composed of two sections: 
    - `#### Settings ####` where we define some variables for input and output files names. 
      You shouldn't have to change these settings, but you can if your data is located in a different folder than what we specified by default.
    - `#### Analysis ####` this is where the _Mash_ analysis is run on each sample. 
      You should not change the code in this section, although examining it is a good way to learn about [Bash programming](https://cambiotraining.github.io/unix-shell/materials/02-programming/01-scripts.html).
- Run the script using `bash scripts/01-mash.sh`.
  If the script is running successfully it should print a message on the screen for each barcode that it processes. 
  Depending on how many barcodes you have, this will take quite a while to finish. <i class="fa-solid fa-mug-hot"></i>
- One the analysis is over, examime the output files to see if all barcodes contain the organism you were expecting. 

:::{.callout-answer collapse=true}

We ran the script as instructed using:

```bash
bash scripts/01-mash.sh
```

While it was running it printed a message on the screen: 

```
Processing barcode01
Loading resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh...
   20679266 distinct hashes.
Streaming from data/fastq_pass/barcode01/ERR10146532.fastq.gz...
   Estimated distinct k-mers in mixture: 210848305
Summing shared...
Reallocating to winners...
Computing coverage medians...
Writing output...
Processing barcode02
Loading resources/mash_db/refseq.genomes_and_plasmids.k21s1000.msh...
   20679266 distinct hashes.
Streaming from data/fastq_pass/barcode02/ERR10146551.fastq.gz...
```

After it finished we see several files in the output folder: 

```bash
ls results/mash
```

```
barcode01_screen_sorted.tsv  barcode04_screen_sorted.tsv  barcode07_screen_sorted.tsv
barcode02_screen_sorted.tsv  barcode05_screen_sorted.tsv  barcode08_screen_sorted.tsv
barcode03_screen_sorted.tsv  barcode06_screen_sorted.tsv  barcode09_screen_sorted.tsv
```

We examined the first 10 lines of every file using the `head` command and the `*` to help us select all files at once: 

```bash
head -n 10 results/mash/*_screen_sorted.tsv
```

```
==> results/bkp-mash/barcode01_screen_sorted.tsv <==
1       1000/1000       42      0       GCF_000279245.1_ASM27924v1_genomic.fna.gz       [23 seqs] NZ_ALDE01000001.1 Vibrio cholerae CP1041(14) vcoCP1041.contig.0, whole genome shotgun sequence [...]
0.999618        992/1000        39      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.995779        915/1000        73      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence
0.977192        616/1000        33      0       ref|NC_010072.1|        Yersinia pestis plasmid pIP1203, aph(3'')-Ib gene and aph(6)-Id gene for aminoglycoside phosphotransferases, APH(3'')-Ib and APH(6)-Id
0.958764        413/1000        53      0       ref|NC_008690.1|        Vibrio sp. TC68 plasmid pTC68, complete sequence
0.931825        227/1000        40      0       ref|NC_017329.1|        Shigella flexneri 2002017 plasmid pSFxv_3, complete sequence
0.93163 226/1000        35      0       ref|NC_005862.1|        Salmonella enterica enterica sv Choleraesuis plasmid cryptic, complete sequence
0.922553        184/1000        34      0       ref|NC_011378.1|        Pasteurella multocida plasmid pCCK1900, complete sequence
0.904677        122/1000        37      0       ref|NC_020280.1|        Edwardsiella ictaluri plasmid pEI3, complete sequence
0.886148        79/1000 38      2.69788e-223    ref|NC_010912.1|        Avibacterium paragallinarum strain A14 plasmid pYMH5, complete sequence

==> results/bkp-mash/barcode02_screen_sorted.tsv <==
1       1000/1000       35      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.999761        995/1000        35      0       GCF_000763075.1_ASM76307v1_genomic.fna.gz       [451 seqs] NZ_JPOP01000001.1 Vibrio cholerae strain RND81 contig_1, whole genome shotgun sequence [...]
0.995882        917/1000        102     0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence
0.977192        616/1000        36      0       ref|NC_010072.1|        Yersinia pestis plasmid pIP1203, aph(3'')-Ib gene and aph(6)-Id gene for aminoglycoside phosphotransferases, APH(3'')-Ib and APH(6)-Id
0.958543        411/1000        55      0       ref|NC_008690.1|        Vibrio sp. TC68 plasmid pTC68, complete sequence
0.932021        228/1000        34      0       ref|NC_005862.1|        Salmonella enterica enterica sv Choleraesuis plasmid cryptic, complete sequence
0.931825        227/1000        42      0       ref|NC_017329.1|        Shigella flexneri 2002017 plasmid pSFxv_3, complete sequence
0.922314        183/1000        40      0       ref|NC_011378.1|        Pasteurella multocida plasmid pCCK1900, complete sequence
0.904677        122/1000        38      0       ref|NC_020280.1|        Edwardsiella ictaluri plasmid pEI3, complete sequence
0.892135        91/1000 43      1.09991e-265    ref|NC_010912.1|        Avibacterium paragallinarum strain A14 plasmid pYMH5, complete sequence

==> results/bkp-mash/barcode03_screen_sorted.tsv <==
0.999905        998/1000        33      0       GCF_000893195.1_ViralProj63437_genomic.fna.gz   NC_015209.1 Vibrio phage CTX chromosome I, complete genome
0.999618        992/1000        34      0       GCF_000234395.1_ASM23439v2_genomic.fna.gz       [15 seqs] NZ_AGUM01000015.1 Vibrio cholerae HC-23A1 vcoHC23A1.contig.14, whole genome shotgun sequence [...]
0.995519        910/1000        53      0       ref|NC_004982.1|        Vibrio cholerae strain O395P plasmid pTLC, complete sequence
0.977569        621/1000        33      0       ref|NC_010072.1|        Yersinia pestis plasmid pIP1203, aph(3'')-Ib gene and aph(6)-Id gene for aminoglycoside phosphotransferases, APH(3'')-Ib and APH(6)-Id
0.958208        408/1000        43      0       ref|NC_008690.1|        Vibrio sp. TC68 plasmid pTC68, complete sequence
0.931825        227/1000        40      0       ref|NC_017329.1|        Shigella flexneri 2002017 plasmid pSFxv_3, complete sequence
0.931825        227/1000        29      0       ref|NC_005862.1|        Salmonella enterica enterica sv Choleraesuis plasmid cryptic, complete sequence
0.922553        184/1000        36      0       ref|NC_011378.1|        Pasteurella multocida plasmid pCCK1900, complete sequence
0.905377        124/1000        33      0       ref|NC_020280.1|        Edwardsiella ictaluri plasmid pEI3, complete sequence
0.884515        76/1000 33      1.0071e-217     ref|NC_010912.1|        Avibacterium paragallinarum strain A14 plasmid pYMH5, complete sequence


... more lines omitted to save space ...
```

We could confirm from this output that all our samples contained a high fraction of _Vibrio cholerae_ sequences. 
This was confirmed by a high percentage of sequence identify (first column) and a high fraction of the database sequences matching our sequences (second column). 

By the 4th or 5th entries in the results tables, although the sequence identity is relatively high (first column), there's a much smaller fraction of matches (second column) suggesting these may be spurious, perhaps due to conserved sequences across species. 
:::
:::


## Summary

::: {.callout-tip}
#### Key Points

- Assessing species content helps confirm the identity of the organisms present in your sequencing data.
- For cultured samples it ensures that your data matches your expected species and helps detect contamination early in the analysis.
- _Mash_ is a tool that matches your reads against known genome sequences (stored in a database), allowing you to identify the closest known species to your sequencing reads.
- The _Mash_ analysis requires two steps:
  - Downloading a suitable database for the organisms of interest (e.g. prokaryotes, eukaryotes, fungi). This only needs to be done once, or if the database is updated.
  - Performing the screening step, using the command `mash screen`.
- Results may indicate contamination if there are species present that shouldn't be in your dataset, such as lab contaminants or environmental microbes.
- Proper interpretation of results involves considering both the sequence identity and number of hits against the database.
- Early screening is sometimes enough to assess that you are dealing with pathogenic strains of the microbe. For example, the presence of the CTX phage, common in O1 El Tor strains of _Vibrio cholerae_. 
:::
