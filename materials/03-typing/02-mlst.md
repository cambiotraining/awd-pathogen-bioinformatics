---
title: MLST
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::


## Multilocus Sequence Typing (MLST)

MLST has become a standard technique for the identification and characterisation of pathogenic bacterial strains. 
Current MLST approaches use a set of "housekeeping genes" for bacteria of interest to classify isolates into groups, according to the mutations they carry in those genes. 
MLST allows to detect changes in the nucleotide sequences of isolates in new outbreak events, complementing other ways to classify strains such as serotyping. 
Therefore, public health laboratories often use MLST to inform and help officials in understanding and managing disease outbreaks.

Groups of isolates with similar mutation profiles in these housekeeping genes are referred to as "sequence types". 
These sequence types are curated by the [PubMLST](https://pubmlst.org/) project. 
For example, sequence type 69 ([ST69](https://pubmlst.org/bigsdb?page=profileInfo&db=pubmlst_vcholerae_seqdef&scheme_id=1&profile_id=69)) is a common type associated with O1 El Tor strains from the current pandemic (7PET). 
Although this method may seem slightly outdated in the era of genomic analysis (as it only relies on 7 genes), it provides a standardised and comparable way to classify strains across different laboratories and locations.

This type of sequence typing can therefore be used to determine if any of our sampled isolates are pathogenic. 
_V. cholerae_ typing relies on seven housekeeping genes (_adk_, _gyrB_, _metE_, _mdh_, _pntA_, _purM_, and _pyrC_). 
Based on this approach, we want to determine which pandemic strain types are dominant in our sampled isolates or whether we have potential novel strain types.
This analysis can be done using _Pathogenwatch_ or using a standalone command line tool `mlst`. 


## MLST with Pathogenwatch

_Pathogenwatch_ uses [PubMLST](https://pubmlst.org/) to run its typing analysis ([details here](https://cgps.gitbook.io/pathogenwatch/technical-descriptions/typing-methods/mlst)) and the results can be seen on the collection view page (@fig-pathogenwatch).

![Example table from the collection view from Pathogenwatch (top), with example of an individual report (bottom)](images/mlst_pathogenwatch.png){#fig-pathogenwatch}

All of the sequence types determined by MLST in our samples seem to be novel (this is indicated by an `*` before the name). 
This seems very surprising, as there must be other strains similar to ours identified in recent outbreaks. 
There are several reasons why we may have obtained this result: 

- The PubMLST database may not contain up-to-date sequence types for most recent _Vibrio_ lineages circulating worldwide. 
- Even if only one of the 7 genes used for typing contains a mutation, MLST already considers it to be a different type from the one in the database. 
- Because we are using Nanopore data, which on average has lower sequencing quality, we may have some errors in the SNP/indel variants identified by the `epi2me` workflow, which now affects our analysis. 

<!-- 
The first step is to download selected public available complete whole genomes of V.cholerae from NCBI which are pandemic strains but also for control we download non-pandemic strains (with known sequence typing in both cases). We download two files for each genome; one with contigs FASTA sequences and other one is annotated genome sequences GFF as described above.
-->

## MLST with command line

TODO - brief explanation

```bash
#!/bin/bash

# create output directory
mkdir results/mlst

# run mlst
mlst --scheme vcholerae results/wf-bacterial-genomes/assemblies/*.fasta > results/mlst/cholera_beirut_mlst.tsv
```

This command outputs a tab-delimited file, which we can open in a spreadsheet software such as _Excel_. 


| barcode25.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(~133) | metE(37) | pntA(12)   | purM(1)    | pyrC(20)  |
| ---------------------- | --------- | -- | ------ | ---------- | --------- | -------- | ---------- | ---------- | --------- |
| barcode26.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(4)    | metE(37) | pntA(227?) | purM(1)    | pyrC(~20) |
| barcode27.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(~121) | metE(37) | pntA(~12)  | purM(1)    | pyrC(~20) |
| barcode28.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(4)    | metE(37) | pntA(227?) | purM(1)    | pyrC(~20) |
| barcode29.medaka.fasta | vcholerae | \- | adk(7) | gyrB(120?) | mdh(209?) | metE(37) | pntA(227?) | purM(172?) | pyrC(~20) |
| barcode30.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(209?) | metE(37) | pntA(227?) | purM(1)    | pyrC(20)  |
| barcode31.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(4)    | metE(37) | pntA(~12)  | purM(1)    | pyrC(~20) |
| barcode32.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(4)    | metE(37) | pntA(227?) | purM(172?) | pyrC(20)  |
| barcode33.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(4)    | metE(37) | pntA(12)   | purM(1)    | pyrC(~20) |
| barcode34.medaka.fasta | vcholerae | \- | adk(7) | gyrB(11)   | mdh(121)  | metE(37) | pntA(~12)  | purM(1)    | pyrC(~20) |

We get a column for each of the 7 genes used for _Vibrio_ sequence typing, with the gene name followed by the allele number in parethesis. 
The allele number is simply an identifier used by PubMLST, and it means that allele has a specific sequence with a certain set of variants ([search for alleles here](https://pubmlst.org/bigsdb?db=pubmlst_vcholerae_seqdef&page=alleleQuery)). 
For example, `adk(7)` corresponds to [allele 7 of the _adk_ gene](https://pubmlst.org/bigsdb?db=pubmlst_vcholerae_seqdef&page=alleleInfo&locus=VCHOL0445&allele_id=7).

The command line version of `mlst` also reports when an allele has an inexact match to the allele in the database, following this notation (copied from [the README documentation](https://github.com/tseemann/mlst)):

Symbol | Meaning | Length | Identity
---   | --- | --- | ---
`n`   | a number means exact intact allele      | 100%            | 100%
`~n`  | novel full length allele _similar_ to n | 100%            | &ge; `--minid`
`n?`  | _partial match_ to known allele         | &ge; `--mincov` | &ge; `--minid`
`-`   | allele _missing_                        | &lt; `--mincov` | &lt; `--minid`
`n,m` | _multiple alleles_                      | &nbsp;          | &nbsp;


## Exercises 

:::{.callout-exercise}
#### MLST (Pathogenwatch)

- Which sequence type were your sequences assigned to?
- How similar are they to ST69?

TODO - improve description of exercise.

:::

:::{.callout-exercise}
#### MLST (command line)

Run your samples through the command line tool `mlst`.

TODO - improve description of exercise.

:::


## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
