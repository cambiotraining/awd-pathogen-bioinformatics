---
title: AMR analysis
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::


## Antimicrobial Resistance (AMR) analysis

According to the [WHO](https://www.who.int/publications/i/item/9789241564748), antimicrobial resistance (AMR) has evolved into a global concern for public health. 
This stems from various harmful bacterial strains developing resistance to antimicrobial medications, including antibiotics. 
As part of our ongoing efforts to enhance cholera disease monitoring, we can delve into identifying AMR patterns connected to our _V. cholerae_ isolates.

Numerous software tools have been created to predict the presence of genes linked to AMR in genome sequences. 
Estimating the function of a gene or protein solely from its sequence is complex, leading to varying outcomes across different software tools. 
It's advisable to employ multiple tools and compare their findings, thus increasing our confidence in identifying which antimicrobial drugs might be more effective for treating patients infected with the strains we're studying.

In this section we will introduce a workflow aimed at combining the results from various AMR tools into a unified analysis.
We will compare its results with AMR analysis performed by _Pathogenwatch_. 

:::{.callout-note}
#### _Nextflow_ workflows

TODO: briefly explain what nextflow is and how it can be used

:::


## _Funcscan_ workflow

Here, we introduce an automated workflow called **[`nf-core/funcscan`](https://nf-co.re/funcscan/1.1.2)** (@fig-funcscan), which uses _Nextflow_ to manage all the software and analysis steps (see information box above).
This pipeline uses five different AMR screening tools: **[ABRicate](https://github.com/tseemann/abricate)**, **[AMRFinderPlus (NCBI Antimicrobial Resistance Gene Finder)](https://www.ncbi.nlm.nih.gov/pathogens/antimicrobial-resistance/AMRFinder/)**, **[fARGene (Fragmented Antibiotic Resistance Gene idENntifiEr)](https://github.com/fannyhb/fargene)**, **[RGI (Resistance Gene Identifier)](https://card.mcmaster.ca/analyze/rgi)**, and **[DeepARG](https://readthedocs.org/projects/deeparg/)**.
This is convenient, as we can obtain the results from multiple approaches in one step. 

![Overview of the `nf-core/funcscan` workflow. In our case we will run the "Antimicrobial Resistance Genes (ARGs)" analysis, shown in yellow. Image source: https://nf-co.re/funcscan/1.1.2]([images/funcscan_metro_workflow.png](https://raw.githubusercontent.com/nf-core/funcscan/1.1.2/docs/images/funcscan_metro_workflow.png)){#fig-funcscan}

This pipeline requires us to prepare a samplesheet CSV file with information about the samples we want to analyse. 
Two columns are required: 

- `sample` --> a sample name of our choice (we will use the same name that we used for the assembly).
- `fasta` --> the path to the FASTA file corresponding to that sample.

You can create this file using a spreadsheet software such as _Excel_, making sure to save the file as a CSV.
Here is an example of our samplesheet, which we saved in a file called `samplesheet_funcscan.csv`: 

```
sample,fasta
isolate01,results/assemblies/isolate01.fasta
isolate02,results/assemblies/isolate02.fasta
isolate03,results/assemblies/isolate03.fasta
isolate04,results/assemblies/isolate04.fasta
isolate05,results/assemblies/isolate05.fasta
isolate06,results/assemblies/isolate06.fasta
isolate07,results/assemblies/isolate07.fasta
isolate08,results/assemblies/isolate08.fasta
isolate09,results/assemblies/isolate09.fasta
isolate10,results/assemblies/isolate10.fasta
```

Once we have the samplesheet read, we can run the `nf-core/funcscan` workflow using the following commands:

```bash
#!/bin/bash

# create output directory
mkdir results/funcscan

# run the pipeline
nextflow run nf-core/funcscan -profile docker \
  --input samplesheet.csv \
  --outdir results/funcscan \
  --run_arg_screening \
  --arg_skip_deeparg
```

The options we used are: 

- `--input` - the samplesheet detailing the input files.
- `--outdir` - the output directory for the results. 
- `--run_arg_screening` - this runs the "antimicrobial resistance gene screening tools". There are also options to run antimicrobial peptide and biosynthetic gene cluster screening ([see documentation](https://nf-co.re/funcscan/1.1.2/parameters#screening-type-activation)).
- `--arg_skip_deeparg` - this skips a step in the analysis which uses the software _DeepARG_, simply because it takes too long to run - but in a real analysis you may want to leave this option on. 

The main output of interest from this pipeline is a CSV file, which contains a summary of the results from all the AMR tools used by the pipeline. 
This summary is produced by a software called [_hAMRonization_](https://github.com/pha4ge/hAMRonization) and the corresponding CSV file is saved in `results/funcscan/reports/hamronization_summarize/hamronization_combined_report.tsv`. 
You can open this file using any standard spreadsheet software such as _Excel_ (@fig-hamronization). 

This file is quite large, containing many columns and rows (we detail all the columns in the information box below). 
The easiest way to query this table is to filter the table based on the column "antimicrobial_agent" to remove rows where no AMR gene was detected (@fig-harmonization). 
This way you are left with only the results which were positive for the AMR analysis. 

![To analyse the table output by _hAMRonization_ in _Excel_ you can go to "Data" --> "Filter". Then, select the dropdown button on the "antimicrobial_agent" column and untick the box "blank". This will only show the genes associated with resistance to antimicrobial drugs.](images/amr_hamronization.svg){#fig-harmonization}

:::{.callout-note collapse=true}
#### _hAMRonization_ report columns (click to expand)

TODO

:::


You can also look at the detailed results of each individual tool, which can be found in the directory `results/funcscan/arg`. 
This directory contains sub-directories for each of the 5 AMR tools used (in our case only 4 folders, because we skipped the _DeepARG_ step):

```bash
ls results/funcscan/arg
```

```
abricate  amrfinderplus  fargene  hamronization  rgi
```

For each individual tool's output folder shown above, there is a report, which is associated with the predicted AMRs for each of our samples. 
In most cases, the report is in tab-delimited TSV format, which can be opened in a standard spreadsheet software such as _Excel_. 
For instance, the AMR report from _Abricate_ for one of our samples looks like this: 

TODO: table

For this sample there were two putative AMR genes detected by _Abicate_, with their associated drugs. 
These genes were identified based on their similarity with annotated sequences from the NCBI database.
For example, the gene "_varG_" was detected in our sample, being similar to the _VarG_ NCBI accession [NG_057468.1](https://www.ncbi.nlm.nih.gov/nuccore/NG_057468.1), which is annotated as as a reference for antimicrobial resistance, in this case to the drug "CARBAPENEM".


## AMR with _Pathogenwatch_

_Pathogenwatch_ also performs AMR prediction using its own [algorithm and curated gene sequences](https://cgps.gitbook.io/pathogenwatch/technical-descriptions/antimicrobial-resistance-prediction/pw-amr). 
The results from this analysis can be seen from the individual sample report, or summarised in the collection view.

![AMR analysis from _Pathogenwatch_. The summary table (top) can be accessed from the sample collections view, by selecting "Antibiotics" from the drop-down on the top-left. The table summarises resistance to a range of antibiotics (red = resistant; yellow = intermediate). More detailed results can be viewed for each individual sample by clicking on its name and opening the sample report (bottom).](images/amr_pathogenwatch.png){#fig-amr_pathogenwatch}

@fig-amr_pathogenwatch shows an example report for the same sample we looked at above with _Abricate_. 
We can see that _Pathogenwatch_ detects AMR for many more antibiotics. 
It does include both carbapenem and chloramphenicol, although it determines that there is "intermediate" resistance for the latter. 

We can conclude that _Pathogenwatch_ is much less conservative in its analysis, compared to the `funcscan` analysis we ran earlier, where we only detected resistance for those two antibiotics. 
 

:::{.callout-important}
#### Which AMR resistance do my strains have?

As you saw from this analysis, it is not easy to answer this question, as different software may give different answers. 
It seems like _Pathogenwatch_ is much less conservative compared to the other software packages, giving resistance to many more antibiotics. 
However, it could be that some of these are "false positives", i.e. the strain circulating in the population is not really resistant to all those antibiotics. 

We do know from this analysis however that we should probably not use antibiotics based on chloramphenicol or carbapenems to treat infected people, and that is very useful information to communicate to the professionals treating hospitalised patients. 
:::


## Exercises

TODO

## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
