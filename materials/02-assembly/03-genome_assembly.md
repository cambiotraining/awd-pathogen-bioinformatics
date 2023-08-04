---
title: Genome assembly
---

::: {.callout-tip}
#### Learning Objectives

- Bulleted list of learning objectives
:::


## Genome Assembly

The next step in our bioinformatics analysis is to assemble a genome from our Nanopore sequencing reads. 
Genome assembly consists of identifying how the sequencing reads we have fit together to reconstruct the genome of the organism. 
In our case, we expect to reconstruct the genome sequences of the _Vibrio cholerae_ isolates we obtained, to identify presence of toxigenic plasmids and potential antimicrobial resistance genes. 

There are different methods to assemble genomes, broadly falling in two categories: **de-novo assembly** and **reference-based consensus assembly**.  
The first method uses no prior information, attempting to reconstruct the genome from the sequencing reads only. 
This method is useful when we don't know which organism(s) to expect as it is unbiased. 
However, it is both computationally intense and challenging to achieve high-quality complete genomes, as it is often difficult to bridge gaps and repetitive regions.  
The second method generates an assembly by using a reference genome as a "scaffold". 
In this case, reads are aligned to the reference genome and used to generate a _consensus_ sequence based on the new mutations identified from the reads. 
This method is less computionally intense and can be used when we know which organism we're working with. 
The disadvantage of this method is that it doesn't work so well if our organism is very diverged from the reference (for example due to large genome rearrangments such as insertions, inversions and repeats). 

In our case, as we are working with cultured _V. cholerae_ samples, we will use the reference-based consensus assembly method. 
We will use a standardised workflow developed by [EPI2ME labs](https://labs.epi2me.io/), a project from Oxford Nanopore Technologies (ONT) that aims to provide the community with several open-source workflows for ONT data.

The workflow we will use is called [**wf-bacterial-genomes**](https://labs.epi2me.io/workflows/wf-bacterial-genomes/), which is built using the _Nextflow_ workflow management software (see more about workflows in our [Appendix](TODO)). 
But before we start the actual analysis, we need to prepare two things: a samplesheet with information about our samples and download a reference genome to use for our assembly.


## Samplesheet

The first step required to run our analysis is to prepare a samplesheet CSV file, describing the samples you would like to analyse before running the pipeline. 
This file can be created in a spreadsheet software and saved in **CSV** format.

The samplesheet file needs to have at least two columns:

- `barcode` - barcode names of the samples, which acts as an identifier attributed to the individual sample during multiplexing; this should essentially match the folder names in the `fastq_pass` folder output by the _Guppy_ basecaller, for example "barcode01", "barcode02", "barcode34", etc. 
- `alias` - provides generic description or custom sample name for each barcode; for example "isolate1", "isolate2", etc.

Here is an example of the samplesheet we used for our samples: 

```bash
cat samplesheet_epi2me.csv
```

```
barcode,alias
barcode25,isolate01
barcode26,isolate02
barcode27,isolate03
barcode28,isolate04
barcode29,isolate05
barcode30,isolate06
barcode31,isolate07
barcode32,isolate08
barcode33,isolate09
barcode34,isolate10
```


## Reference genome

TODO - transfer this back from preparing_data.


## Running `epi2me-labs/wf-bacterial-genomes`

We will now start our analysis by running the `epi2me-labs/wf-bacterial-genomes` pipeline to generate genome assemblies from the isolates' sequencing reads. 
Make sure that you are inside your project directory, which contains 'data', 'scripts' and 'resources' directories. 
We will run the pipeline in the reference-based assembly mode, instead of de novo assembly. 

We have put our commands in a shell script, shown below. 
The script first creates a folder inside 'results' to save the output files that the pipeline generates and then runs the _Nextflow_ command to execute the pipeline.

```bash
#!/bin/bash

# create output directory
mkdir -p results/wf-bacterial-genomes

# run the workflow
nextflow run epi2me-labs/wf-bacterial-genomes -profile standard \
  --sample_sheet samplesheet_epi2me.csv \
  --fastq data/fastq_pass \
  --out_dir results/wf-bacterial-genomes \
  --threads 4 \
  --reference_based_assembly True \
  --reference resources/reference_genome/GCF_937000105.1_CNRVC190243_genomic.fna \
  --isolates True \
  --resfinder_version 4.3.2 \
  --mlst_version 2.23.0 \
  --medaka_consensus_model r941_min_fast_g507 \
  --medaka_variant_model r941_min_fast_variant_g507
```

Here is a detailed explanation of the options used: 

- `-profile standard` → runs the pipeline using _Docker_ to manage all the bioinformatic software required to run the pipeline. An alternative is to use the _Singularity_ software, in which case you can change this option to `-profile singularity`.
- `--sample_sheet` → the path to the samplesheet CSV file we created earlier. 
- `--fastq` → the path to the directory where the FASTQ files are in. The pipeline expects to find individual barcode folders within this, so we use the `fastq_pass` directory generated by the _Guppy_ basecaller. 
- `--out_dir` → the path to the output directory where all the results files will be saved.
- `--threads 4` → indicates that we want to use 4 CPUs for parallel processing, which should speed the computation. 
- `--reference_based_assembly True` → uses reference-based assembly as we explained above. 
- `--reference` → the path to the FASTA file containing the reference genome we want to use. In this case, we are using the genome downloaded earlier. 
- `--isolates True` → turns on the option to run AMR analysis and typing using _ResFinder_ and _MLST_, respectively (we will detail more about these steps later). 
- `--resfinder_version` and `--mlst_version` → specify which version of the [_ResFinder_](https://pypi.org/project/resfinder/) and [_MLST_](https://github.com/tseemann/mlst/releases) software packages we want to use. It is a good idea to use the latest versions available, which you can see in the links provided.
- `--medaka_consensus_model` and `--medaka_variant_model` → specify the models that the _medaka_ software should use to do variant calling in the data. The model name follows the structure `{pore}_{device}_{mode}_{version}`. See more details about this in the [medaka models documentation](https://github.com/nanoporetech/medaka#models). **Note:** for recent versions of Guppy (>6) there is no exact matching model from `medaka`. The recommendation is to use the model for the latest version available; a list of supported models can be found on the [`medaka` GitHub repository](https://github.com/nanoporetech/medaka/tree/master/medaka/data).

When you launch the pipeline, you should see some progress of the analysis printed on the screen, which will update as the analysis moves on. 
Here is an example snapshot of the output you may see: 

```
--------------------------------------------------------------------------------
This is epi2me-labs/wf-bacterial-genomes v0.3.0-g0d2379f.
--------------------------------------------------------------------------------
Checking fastq input.
executor >  local (9)
[c3/240517] process > validate_sample_sheet                                [100%] 1 of 1 ✔
[62/1625d7] process > fastcat (4)                                          [ 20%] 1 of 5
[-        ] process > calling_pipeline:alignReads                          [  0%] 0 of 1
[-        ] process > calling_pipeline:readStats                           -
[-        ] process > calling_pipeline:coverStats                          -
[-        ] process > calling_pipeline:splitRegions                        -
[-        ] process > calling_pipeline:medakaNetwork                       -
[-        ] process > calling_pipeline:medakaConsensus                     -
[-        ] process > calling_pipeline:medakaVariantConsensus              -
[-        ] process > calling_pipeline:medakaVariant                       -
[-        ] process > calling_pipeline:runProkka                           -
[45/bb86a2] process > calling_pipeline:prokkaVersion                       [100%] 1 of 1 ✔
[4d/cbb37c] process > calling_pipeline:medakaVersion                       [100%] 1 of 1 ✔
[60/2e2037] process > calling_pipeline:mlstVersion                         [100%] 1 of 1 ✔
[7e/52122f] process > calling_pipeline:getVersions                         [100%] 1 of 1 ✔
[65/0a15ba] process > calling_pipeline:getParams                           [100%] 1 of 1 ✔
[-        ] process > calling_pipeline:makeReport                          -
[4f/a870e9] process > calling_pipeline:collectFastqIngressResultsInDir (1) [100%] 1 of 1
[-        ] process > output                                               -
```

Once the pipeline finishes, it should print a message similar to this: 

```
Completed at: 02-Aug-2023 14:48:33
Duration    : 1h 25m 59s
CPU hours   : 5.4
Succeeded   : 140
```


## Assembly outputs

You can run `ls results/wf-bacterial-genomes` from your working directory to view the output files generated by the pipeline.
The primary outputs of the pipeline include:

- `<ALIAS>.medaka.fasta.gz` → FASTA consensus sequences scaffolded from the provided reference sequence; these files are compressed (with `.gz` file format).
- `<ALIAS>.medaka.vcf.gz` → VCF files containing variants (mutations) identified in the sample, compared to the reference genome; these are also compressed (with `.gz` file format).
- `<ALIAS>.prokka.gff` → a GFF file containing the gene annotation of the consensus sequence using the _prokka_ software.
- `<ALIAS>_resfinder_results` → folders containing the output directory from the _ResFinder_ software used for AMR analysis.
- `<ALIAS>.mlst.json` → a JSON file containing the typing results using the _MLST_ software.
- `wf-bacterial-genomes-report.html` → an HTML report document detailing QC metrics and the primary findings of the workflow.

The main files that we will analyse are the genome assemblies for each isolate, i.e. the FASTA files. 
The compressed FASTA (`.fasta.gz`) files need to be decompressed, as some of the tools used in downstream analysis only work with decompressed files, i.e. `.fasta` format. 

The following command decompresses the generated fasta files and we then move them to a separate folder called "assemblies", for our convenience:

```bash
# decompress all the FASTA files
gunzip results/wf-bacterial-genomes/*.fasta.gz

# create folder for the assemblies
mkdir results/wf-bacterial-genomes/assemblies/

# move the files in to the new folder
mv results/wf-bacterial-genomes/*.fasta results/wf-bacterial-genomes/assemblies/
```


## EPI2ME QC report

The first file we can open is the HTML report generated by the workflow. 
This is an interactive report that we can open from our file browser <i class="fa-solid fa-folder"></i>, by double-clicking the `wf-bacterial-genomes-report.html` file, which will open it on our internet browser (Figure). 

![Screenshot of the HTML report generated by the `epi2me-labs/wf-bacterial-genomes` pipeline. You can navigate to different sections of the report from the top of the page and change the samples displayed from the drop-down button next to each section.](images/epi2me_report.svg)

Generally, the report will contain the following sections: 

- **Read summary** → shows basic quality metrics about our raw reads. For ONT data an average read quality above 8 is considered acceptable. Average quality of 20 or above is considered excellent (this is common for short-read Illumina data). 
- **Depth** → shows a plot of the depth of coverage along the reference genome, representing the average number of reads aligning to each position of the genome. As explained in the report itself, we usually want a depth of coverage > 50 for confidently identifying variants (mutations) in our sequences. There may be regions of the reference genome where the coverage completely drops to zero. Those are likely to be regions missing from our isolate, for example due to missing plasmids. 
- **Variant calling** → this table summarises the mutations (variants) identified in each sample. See the box below for the meaning of the columns on this table.
- **Annotations** → a table with the gene annotations performed by _prokka_. This table is searcheable, so you can see if the genes from the CT phage (CTX) are present in your samples (these include the toxin-encoding genes _ctxA_ and _ctxB_), as that would be an indication that you are working with a pathogenic strain. 
- **Antimicrobial resistance (AMR)** → the results of potential antibiotic resistance, based on an analysis with the _ResFinder_ software. We will discuss this more later. 
- **Multilocus sequence typing (MLST)** → the results from typing your sequences based on the popular [PubMLST database](https://pubmlst.org/). We will discuss this more later. 
- **Software versions** and **Workflow parameters** → details about how the pipeline was run. 

:::{.callout-note}
#### Variant calling nomenclature

"Variant calling" is the process of identifying changes in the genome of an organism, which we usually refer to as "variants" or sometimes "mutations".

- Single Nucleotide Polymorphism (SNP) refers to a change of a single base in the sequence.
- Multiple Nucleotide Polymorphism (MNP) refers to multiple SNPs occurring adjacent to each other.
- Insertion or deletion (indel) refers to a change where the alleles are of different lenghts.

Here is a schematic representation of these three cases: 

```
 SNP     MNP     Indel
ATGGT   ATGGT   ATG--GT
ATCGT   AACTT   ATGCCGT
  ↑      ↑↑↑       ↑↑
```

In most cases there are only two alleles for each variant (as in the example above), but sometimes multiple alleles may be present in the population, and these are referred to as "multiallelic sites". 
This is relatively rare and a high prevalence of multiallelic variants may indicate errors rather than true variations. 
:::


## Exercises

:::{.callout-exercise}
#### Running epi2me workflow

TODO

:::

:::{.callout-exercise}
#### QC report

TODO

- Did all your samples have an average depth of coverage above 50x across the two chromosomes?
- 

:::


## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
