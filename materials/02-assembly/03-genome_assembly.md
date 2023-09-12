---
title: Genome assembly
---

::: {.callout-tip}
#### Learning Objectives

After this section you should be able to:

- Describe the main steps involved in _de novo_ genome assembly.
- Discuss the impact of genome coverage in the final assembly.
- List the individual software tools used in the assembly steps.
- Apply a script to automate the process of assembly across several samples.
:::

## Genome Assembly

The next step in our analysis is **genome assembly**, which involves piecing together a complete genome from the sequencing data we've obtained. 
This is a critical process in our study of _Vibrio cholerae_ samples, as it allows us to identify the specific strains, determine their pathogenicity, and detect toxigenic and antimicrobial resistance genes.

There are two main approaches to genome assembly: 

- **De-novo assembly:** this uses no prior information, attempting to reconstruct the genome from the sequencing reads only. 
  It's suitable when we're unsure about the organism or when it's genetically diverse (so there is no single reference genome that is representative of the full diversity observed in the species). 
  However, it's computationally intensive and challenging to achieve highly accurate results due to difficulties in handling gaps and repetitive regions.  
- **Reference-based assembly:** this method uses a known genome as a guide. 
  It aligns the reads to the reference genome and identifies new variations from those reads. 
  It's less computationally demanding and works well when we have a good idea of the organism's identity. 
  Yet, it might not perform well if the organism is significantly different from the reference genome.

In our study of _Vibrio cholerae_, we have opted for the **_de novo_** approach. 
Although there are many [high-quality genomes available on NCBI](https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=666&annotated_only=true&refseq_annotation=true&typical_only=true), this species is notorious for having a plastic genome, with the presence of several mobile genetic elements and gene exchange happening through conjugation and phage-mediated transduction ([Montero et al. 2023](https://doi.org/10.3389/fmed.2023.1155751) and [Ramamurthy et al. 2019](https://doi.org/10.3389%2Ffpubh.2019.00203)). 
Therefore, a reference-based assembly may not be the most suited for this species, as we might miss important genes from our samples, if they are not present in the reference genome that we choose. 

Here's a breakdown of the steps we'll take:

* **Downsample** the FASTQ files for a target depth of coverage of approximately 100x.
* **Assemble** the reads into contiguous fragments.
* **Polish** those fragments to correct systematic sequencing errors common in Nanopore data.
* **Annotate** the assembled fragments, by identifying the position of known bacterial genes.

We'll provide a detailed procedure for a single sample, and later, we'll offer a script that automates these steps for multiple samples simultaneously.

:::{.callout-note}
#### Terminology: genome coverage

Genome coverage refers to the average number of times a specific base pair in a genome is read or sequenced during the process of DNA sequencing. 
It indicates how thoroughly the genome has been sampled by the sequencing technique. 
Higher coverage means that a base pair has been read multiple times, increasing the confidence in the accuracy of the sequencing data for that particular region of the genome. 
Genome coverage is an important factor in determining the quality of genome assemblies and the ability to detect variations (such as new mutations or sequence rearragements).
:::


## Step-by-step bacterial assembly

As we mentioned earlier, _de novo_ assembly of genomes is a challenging process. 
Ideally, we want to achieve a "perfect genome", i.e. a complete representation of the individual's genome, with no errors and no missing gaps.
Although challenging, it is possible to achieve near-perfect genomes, in particular when multiple types of data are available: long reads for assembling more difficult regions and short reads for correcting the high error rates of long reads ([Wick et al. 2023](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1010905)). 

In this section, we introduce a simplified version of the tutorial "[Assembling the perfect bacterial genome](https://github.com/rrwick/Perfect-bacterial-genome-tutorial/wiki)", which is suitable for nanopore-only data. 

We start by activating our software environment, to make all the necessary tools available: 

```bash
mamba activate assembly
```


### Sampling: `rasusa`

The first step in our analysis is to sample a fraction of our original reads to match a minimum specified genome coverage. 
This may seem counterintuitive, as we may expect that more data is always better. 
While this is generally the case, it turns out that for genome assembly there is a plateau at which the tradeoff between having too much data doesn't outweight the computational costs that come with it. 
For example, assembling a _Vibrio_ genome with an average depth of coverage of 500x might take 5h, while one with 100x might take 1h, with very similar results in the final assembly. 
The computational burden is especially relevant when we are running analysis on a local computer, rather than on a HPC cluster (where we can run analysis in parallel), as each sample will have to be processed sequentially. 

To be able to run all analyses on a local computer, we'll adjust the number of FASTQ reads we're working with to reach a coverage depth of about 100 times, using a tool called [_Rasusa_](https://github.com/mbhall88/rasusa). 
This tool is designed to handle reads of various lengths, which is common with ONT data. 
It randomly picks reads to make sure the average coverage across a genome of a certain size (chosen by us) is achieved.  
This process considers the lengths of the reads. 
For instance, if the average ONT read is longer, we'll need fewer reads to cover the genome compared to when the average read is shorter. 
Imagine our genome is around 1 million bases long, and we aim for a 20-fold coverage. 
If our reads average around 1,000 bases, we'd need about 200,000 reads. 
But if the average read is 10,000 bases, we'd only need 2,000 reads instead. 
This is a simplified explanation, as our reads have various lengths, but it captures what _Rasusa_ is working towards.

To run _Rasusa_ on a single sample (in this example we are doing `barcode26`), the following commands can be used: 

```bash
# create output directory
mkdir results/rasusa

# temporarily combine FASTQ files from Guppy
cat data/fastq_pass/barcode26/*.fastq.gz > results/rasusa/combined_barcode26.fastq.gz

# downsample files
rasusa --input results/rasusa/combined_barcode26.fastq.gz --coverage 100 --genome-size 4m --output results/rasusa/barcode26_downsampled.fastq.gz

# remove the combined FASTQ file to save space
rm results/rasusa/combined_barcode26.fastq.gz
```

- During the basecalling procedure, Guppy will often generate multiple FASTQ files for each barcode. 
  We first need to combine these into a single file, as `rasusa` only accepts a single file as input. 
  We achieved this using the `cat` command.
- For `rasusa` we used the following options: 
  - `--input` specifies the input FASTQ file.
  - `--coverage` specifies our desired depth of coverage; 100x is a good minimum for genome assembly.
  - `--genome-size` specifies the predicted genome size. Of course we don't know the _exact_ size of our genome (we're assembling it after all), but we known approximately how big the _Vibrio_ genome is based on other genomes available online, such as [this genome](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_937000105.1/) from a 7PET strain, which is 4.2 Mb long. 
  - `--output` specifies the output FASTQ file.
- At the end we removed the combined FASTQ file, to save space on the computer (these files can be quite large!).

After `rasusa` runs, it informs us of how many reads it sampled: 

```
 Target number of bases to subsample to is: 400000000
 Gathering read lengths...
 202685 reads detected
 Keeping 167985 reads
 Actual coverage of kept reads is 100.00x
 Done 🎉
```

Note that the sampling procedure is random, so you may get slightly different results every time you run it. 

Sometimes, you may not have enough reads to achieve the desired coverage. 
In that case, `rasusa` instead keeps all the reads, with an appropriate message, for example for our `barcode25` sample we got: 

```
Requested coverage (100.00x) is not possible as the actual coverage is 37.27x - output will be the same as the input
```

:::{.callout-important}
#### Low genome coverage

For genome assembly, we do not recommend that you go much lower than 100x coverage. 
A low depth of coverage leads to difficulty in:

- Distinguishing errors from the true base; low coverage generally results in higher error rates.
- Generating a contiguous genome assembly; low coverage generally results in a more fragmented genome.
:::


### Assembly: `flye`

Now that we have downsampled our reads, we are ready for the next step of the analysis, which is the genome assembly. 
We will use the software [_Flye_](https://github.com/fenderglass/Flye), which is designed for _de novo_ assembly of long-read sequencing data, particularly from technologies like Oxford Nanopore or PacBio.
However, [many other assembly tools](https://en.wikipedia.org/wiki/De_novo_sequence_assemblers) are available, and you could explore alternatives.

Continuing from our example `barcode26` sample, here is the `flye` command that we could use: 

```bash
# create output directory
mkdir results/flye

# run the assembly - this step takes some time to run!
flye --nano-raw results/rasusa/barcode26_downsampled.fastq.gz --threads 8 --out-dir results/flye/isolate2/ --asm-coverage 100 --genome-size 4m
```

- `--nano-raw` specifies the input FASTQ file with our reads. 
- `--threads` specifies how many CPUs we have available for parallel computations.
- `--out-dir` specifies the output directory for our results; in this case we used a more friendly name that corresponds to our isolate ID.
- `--asm-coverage` and `--genome-size` specifies the coverage we want to consider for a certain genome size; in our case these options could be left out, as we already downsampled our FASTQ files to this depth; but we can keep the same values here that we used for `rasusa`. 

One important thing to note about _Flye_ is that it has two ways to specify input files: `--nano-raw` (which we used) and `--nano-hq`. 
As the ONT chemistry and basecalling software improve, the error rates of the reads also improve. 
If your reads are predicted to have <5% error rate, then you can use `--nano-hq` option to specify your input. 
This is the case if you used Guppy version 5 or higher with basecalling in _super accurate_ (SUP) mode. 
This basecalling mode takes substantially longer to run, but it does give you [better assemblies](https://github.com/Kirk3gaard/2023-basecalling-benchmarks), so it may be worth the extra time, if you want the highest-quality assemblies possible. 
In our example, the basecalling was done in "fast" mode, so we used the `--nano-raw` input option instead.

After `flye` completes running, it generates several output files: 

```bash
ls results/flye/isolate2
```

```
00-assembly   40-polishing                assembly_graph.gfa  params.json
10-consensus  assembly.fasta              assembly_graph.gv
20-repeat     assembly.fasta.fai          assembly_info.txt
30-contigger  assembly.fasta.map-ont.mmi  flye.log
```

The main file of interest to us is `assembly.fasta`, which is the genome assembly in the standard FASTA file format. 
Another file of interest is `flye.log`, which contains information at the bottom of the file about the resulting assembly: 

```bash
tail -n 8 results/flye/isolate2/flye.log
```

```
Total length:   4219745
Fragments:      3
Fragments N50:  3031589
Largest frg:    3031589
Scaffolds:      0
Mean coverage:  98
```

We can see for our example run that we have a total assembly length of ~4.2 Mb, which matches our expected genome size. 
The number of final fragments was 3, and given that _Vibrio cholerae_ has 2 chromosomes, this is not bad at all - we must have been able to assembly the two chromosomes nearly completely. 
The largest fragment is ~3 Mb, which again from our knowledge of other _Vibrio_ genomes, probably corresponds to chromosome 1. 
And we can see the final depth of coverage of the genome is 98x, which makes sense, since we sampled our reads to achieve approximately 100x. 

Sometimes you may end up with more fragmented genome assemblies, in particular if your coverage is not good. 
For the example we showed earlier, where `rasusa` reported our reads were only enough for ~37x coverage, our flye assembly resulted in more than 30 fragments. 
While this is worse than a near-complete assembly, it doesn't mean that the genome assembly is useless. 
We should still have recovered a lot of the genes, and even a fragmented assembly can be used to identify sequence types and pathogenic and AMR genes. 


### Polishing: `medaka`

As previously mentioned, ONT reads generally come with higher error rates compared to other technologies like the short-read Illumina sequencing, which often has less than 1% error rate. 
Even with the most recent ONT chemistry updates, the error rates are still around 5%, a significant figure that can potentially introduce incorrect base calls into our final assembly. 
While the `flye` software does address some of these errors, its error-correcting algorithm wasn't tailored specifically to address the systematic errors observed in ONT data.
Consequently, as an added step following assembly, we can review the FASTA file of our assembly and rectify any potential errors that may have been retained from the original reads. This process is commonly known as **polishing** the assembly.

To perform polishing, we can employ the [_Medaka_](https://github.com/nanoporetech/medaka) software developed by ONT. 
More specifically, we can utilize the `medaka_consensus` tool, which is expressly designed to complement genome assemblies created using _Flye_. 
The approach involves aligning the original reads to the newly assembled genome. 
Then, it involves identifying the correct base for each position in the genome, determined by analyzing the "pileup" of reads that align to that specific position. 
This is facilitated by a machine learning model trained on ONT data, which accounts for the distinct error patterns and biases inherent in this type of sequencing information.

Continuing our example for `barcode26` / `isolate2`, we could run the following command: 

```bash
medaka_consensus -t 8 -i results/rasusa/barcode26_downsampled.fastq.gz -d results/flye/isolate2/assembly.fasta -o results/medaka/isolate2 -m r941_min_fast_g507
```

- `-t` specifies the number of CPUs (threads) available to use for parallel computation steps.
- `-i` specifies the FASTQ file with the reads used for the assembly.
- `-d` specifies the FASTA file with the assembly we want to polish.
- `o` specifies the output directory for our results. 
- `-m` specifies the _Medaka_ model to use for identifying variants from the aligned reads. 

The last option requires some further explanation. 
The _Medaka_ model name follows the structure `{pore}_{device}_{mode}_{version}`, as detailed in the [medaka models documentation](https://github.com/nanoporetech/medaka#models).
For example, the _Medaka_ model we specified was "r941_min_fast_g507", which means we used R9.4.1 pores, sequenced on a MinION, basecalling in "fast" mode using Guppy version 5.0.7.
A list of supported models can be found on the [`medaka` GitHub repository](https://github.com/nanoporetech/medaka/tree/master/medaka/data). 
In reality, we used Guppy version 6, but for recent versions of Guppy (>6) there is no exact matching model.
The recommendation in that case is to use the model for the latest version available. 

The output from this step generates several files: 

```bash
ls results/medaka/isolate2
```

```
calls_to_draft.bam  calls_to_draft.bam.bai  consensus.fasta  consensus.fasta.gaps_in_draft_coords.bed  consensus_probs.hdf
```

The most important of which is the file `consensus.fasta`, which contains our final polished assembly. 


### Annotation: `bakta`

Although we now have a genome assembly, we don't yet know which genes might be present in our assembly or where they are located. 
This process is called **genome annotation**, and for bacterial genomes we can do this using the software [_Bakta_](https://github.com/oschwengers/bakta). 
This software takes advantage of the vast number of bacterial gene sequences in public databases, to aid in the identification of genes in our new assembly.
_Bakta_ achieves this by looking for regions of our genome that have high similarity with those public sequences. 


#### `bakta` database

In order to run `bakta` we first need to download the database that it will use to aid the annotation. 
This can be done with the `bakta_db` command. 
There are two versions of its database: "light" and "full". 
The "light" database is smaller and results in a faster annotation runtime, at the cost of a less accurate/complete annotation. 
The "full" database is the recommended for the best possible annotation, but it is much larger and requires longer runtimes. 

For the purposes of our tutorial, we will use the "light" database, but if you were running this through your own samples, it may be desirable to use the "full" database. 
To download the database you can run the following command (if you are attending our workshop, please don't run this step, as we already did this for you):

```bash
# make a directory for the database
mkdir -p resources/bakta_db

# download the "light" version of the database
bakta_db download --output resources/bakta_db/ --type light
```

After download you will see several newly created files in the output folder: 

```bash
ls resources/bakta_db/db-light/
```

```
amrfinderplus-db  bakta.db                       ncRNA-genes.i1p    oric.fna  pfam.h3p   rRNA.i1p
antifam.h3f       expert-protein-sequences.dmnd  ncRNA-regions.i1f  orit.fna  pscc.dmnd  rfam-go.tsv
antifam.h3i       ncRNA-genes.i1f                ncRNA-regions.i1i  pfam.h3f  rRNA.i1f   sorf.dmnd
antifam.h3m       ncRNA-genes.i1i                ncRNA-regions.i1m  pfam.h3i  rRNA.i1i   version.json
antifam.h3p       ncRNA-genes.i1m                ncRNA-regions.i1p  pfam.h3m  rRNA.i1m
```

:::{.callout-important}
You only need to download the `bakta` database once, and it may be a good idea to save it in a separate folder that you can use again for a new analysis. 
This should save you substantial time and storage space. 
:::


#### `bakta` annotation {#sec-bakta-annot}

To run the annotation step we use the `bakta` command, which would be the following for our `barcode26` / `isolate2` sample:

```bash
# create output directory
mkdir results/bakta

# run the annotation step
bakta --db resources/bakta_db/db-light/ --output results/bakta/isolate2 --threads 8 results/medaka/isolate2/consensus.fasta
```

- `--db` is the path to the database folder we downloaded earlier.
- `--output` is the directory we want to output our results to.
- `--threads` is the number of CPUs (threads) we have available for parallel computation.
- At the end of the command we give the path to the FASTA file that we want to annotate.

Several results files are generated: 

```bash
ls results/bakta/isolate2
```

```
consensus.embl  consensus.ffn  consensus.gbff  consensus.hypotheticals.faa  consensus.json  consensus.png  consensus.tsv
consensus.faa   consensus.fna  consensus.gff3  consensus.hypotheticals.tsv  consensus.log   consensus.svg  consensus.txt
```

Many of these files contain the same information but in different file formats. 
The main file of interest is `consensus.gff3`, which we will use in a later chapter covering [phylogenetic analysis](../03-typing/03-phylogeny.md). 
The tab-delimited file `consensus.tsv` can conveniently be opened in a spreadsheet program such as _Excel_. 

Also, using the command line tool `grep`, we can quickly search for genes of interest. 
For example, we can see if the genes from the CT phage (CTX) are present in your samples (these include the toxin-encoding genes _ctxA_ and _ctxB_):

```bash
grep -i "ctx" results/bakta/isolate2/consensus.tsv
```

```
contig_2        cds     2236513 2237289 +       LBGGEL_19385    ctxA    cholera enterotoxin catalytic subunit CtxA      BlastRules:WP_001881225, NCBIProtein:AAF94614.1
contig_2        cds     2237286 2237660 +       LBGGEL_19390    ctxB    cholera enterotoxin binding subunit CtxB        BlastRules:WP_000593522, NCBIProtein:AAF94613.1, SO:0001217, UniRef:UniRef50_P01556
```

Both subunits are found in our assembly, suggesting our isolate is a pathogenic strain of _Vibrio cholerae_. 

And this concludes our assembly steps: we now have an **annotated genome assembly** produced from our ONT reads. 


## Assembly workflow {#sec-workflow}

In the previous section we applied our assembly workflow to a single sample. 
But what if we had 20 samples? 
It would be quite tedious and error-prone to have to copy/paste and modify these commands so many times. 

Instead, we can automate our analysis using some programming techniques, such as a _for loop_, to repeat the analysis across a range of samples. 
This is what we've done for you, having already prepared a shell script that runs through these steps sequentially for any number of samples (if you are interested, the full script is available [here](../../course_files/participants/minimal/scripts/02-assembly.sh)).
Our script is composed of two parts: 

- **Settings:** at the top of the script you will find a section `#### Settings ####`, where you can define several options to run the analysis (we will detail these below).
- **Pipeline:** further down you find a section `#### Assembly pipeline ####`, which contains the commands to run the full analysis from raw sequences to an annotated assembly. 
  The code we use looks more complex, as we make use of several (advanced) programming techniques, but the basic steps are the same as those we detailed step-by-step in the previous section.

As a user of our script, the most important part is the `#### Settings ####`. 
The following settings are available: 

- `samplesheet` → the path to a CSV file with at least two columns:  
  - `sample` - sample name of your choice for each barcode; for example "isolate1", "isolate2", etc.
  - `barcode` - barcode folder names of each samples; this should essentially match the folder names in the `fastq_pass` folder output by the _Guppy_ basecaller, for example "barcode01", "barcode02", "barcode34", etc. 
  - you can include other columns in this sheet (such as metadata information), as long as the first two columns are the ones explained above.
- `fastq_dir` → the path to the directory where the FASTQ files are in. The pipeline expects to find individual barcode folders within this, so we use the `fastq_pass` directory generated by the _Guppy_ basecaller. 
- `outdir` → the path to the output directory where all the results files will be saved.
- `threads` → how many CPUs are available for parallel processing. 
- `genome_size` → the predicted genome size for the bacterial we are assembling (4m is recommended for _Vibrio_).
- `coverage` → the desired coverage for subsampling our reads to.
- `medaka_model` → the medaka model to use for the polishing step (as explained above). 
- `bakta_db` → the path to the `bakta` database folder.

Here is an example of the samplesheet for our samples: 

```
sample,barcode
isolate01,barcode25
isolate02,barcode26
isolate03,barcode27
isolate04,barcode28
isolate05,barcode29
isolate06,barcode30
isolate07,barcode31
isolate08,barcode32
isolate09,barcode33
isolate10,barcode34
```

We have 10 isolates (number 1 to 10), corresponding to different barcodes. 
The samplesheet therefore makes the correspondence between each sample's name and its respective barcode folder. 

One we have this samplesheet and we edit all the options in the script, we can run the script using `bash`: 

```bash
bash scripts/02-assembly.sh
```

Our script in this case was called `02-assembly.sh` and we had saved it in a folder called `scripts`. 
Note that all the file paths specified in the "Settings" of the script are relative to the folder where we run the script from. 
In our case, we had a folder named `awd_workshop`, where we are running the analysis from, and that is where we ran the script from. 

The script will take quite a while to run (up to 1h per sample, using 8 CPUs on our computers), so you may have to leave your computer doing the hard work overnight. 
As it runs, the script prints some progress messages on the screen: 

```
Processing sample 'isolate01' with barcode 'barcode25'
        2023-08-09 22:41:38      Concatenating reads...
        2023-08-09 22:41:42      Subsampling reads with rasusa...
        2023-08-09 22:42:47      Assembling with flye...
        2023-08-09 22:55:37      Polishing with medaka...
        2023-08-09 22:59:41      Annotating with bakta...
        2023-08-09 23:24:47      Finished assembly pipeline for 'isolate01'.
                                 Assembly file in: results/assemblies/isolate01.fasta
                                 Annotation file in: results/assemblies/isolate01.gff

Processing sample 'isolate02' with barcode 'barcode26'
        2023-08-09 23:24:47      Concatenating reads...
        2023-08-09 23:24:56      Subsampling reads with rasusa...
        2023-08-09 23:26:32      Assembling with flye...
        2023-08-09 23:52:36      Polishing with medaka...
```

Several output files are generated in the directory you specified as `outdir`. 
Here is what we have for our example data: 

```bash
ls results/assemblies
```

```
01-rasusa        isolate02.gff    isolate06.fasta  isolate09.gff
02-flye          isolate03.fasta  isolate06.gff    isolate10.fasta
03-medaka        isolate03.gff    isolate07.fasta  isolate10.gff
04-bakta         isolate04.fasta  isolate07.gff    summary_metrics.csv
isolate01.fasta  isolate04.gff    isolate08.fasta
isolate01.gff    isolate05.fasta  isolate08.gff
isolate02.fasta  isolate05.gff    isolate09.fasta
```

We get a folder with the results of each step of the analysis (this matches what we went through in detail in the step-by-step section) and two files per sample: a FASTA file with the polished assembly and a GFF file with the gene annotations. 
We also get a CSV file called `summary_metrics.csv`, which contains some useful statistics about our assemblies. 
We will look at these in the next chapter on [quality control](04-assembly_quality.md).


## Exercises {#sec-ex-assembly}

<i class="fa-solid fa-triangle-exclamation" style="color: #1e3050;"></i> 
For these exercises, you can either use the dataset we provide in [**Data & Setup**](../../setup.md), or your own data. 

:::{.callout-exercise}
#### Running assembly script

As covered in the sections above, the genome assembly process involves several steps and software.
We provide a script that performs the assemly pipeline for a set of samples specified by the user (using a _for loop_ as detailed in @sec-workflow). 

- In the folder `scripts` (within your analysis directory) you will find a script named `02-assembly.sh`. 
- Open the script, which you will notice is composed of two sections: 
    - `#### Settings ####` where we define some variables for input and output files names. 
      We already include default settings which are suitable for the "Ambroise 2023" data, but **you may have to change some settings** to suit your data.
    - `#### Analysis ####` this is where the assembly workflow is run on each sample as detailed in @sec-workflow. 
      You should not change the code in this section, although examining it is a good way to learn about [Bash programming](https://cambiotraining.github.io/unix-shell/materials/02-programming/01-scripts.html) (this one is quite advanced, so don't worry if you don't understand some of it).
- One of the main inputs to the script is a CSV file with two columns specifying your sample IDs and their respective barcode folder name. 
  Using _Excel_, create this file for your samples, as explained in @sec-workflow.
  Save it as `samplesheet.csv` in your analysis directory.
- Activate the software environment: `mamba activate assembly`
- Run the script using `bash scripts/02-assembly.sh`.
  If the script is running successfully it should print a message on the screen as the samples are processed. 
  Depending on how many barcodes you have, this will take quite a while to finish (up to 1h per sample). <i class="fa-solid fa-mug-hot"></i>
- One the analysis finishes you can confirm that you have several files in the output folder. 
  We will analyse these files in the [next chapter](04-assembly_quality.md)

:::{.callout-answer collapse=true}

We opened the script `02-assembly.sh` and these are the settings we used: 

- `samplesheet="samplesheet.csv"` - the name of our samplesheet CSV file, detailed below.
- `fastq_dir="data/fastq_pass"` - the name of the directory where we have our barcode folders from basecalling with Guppy.
- `outdir="results/assemblies"` - the name of the directory where we want to save our results.
- `threads="16"` - the number of CPUs we have available for parallel computations. You can check how many CPUs you have using the command `nproc --all`.
- `genome_size="4m"` - the predicted genome size for the organism we are assembling. We use the _Vibrio cholerae_ genome size. 
- `coverage="100"` - the coverage we want to downsample our sequencing reads to.
- `medaka_model="r941_min_hac_g507"` - the model for the _Medaka_ software. For the "Ambroise 2023" data basecalling was performed using the high accuracy ("hac") mode, sequenced on a MinION platform using R9.4.1 pores. So, we chose the model that fits with this. 
- `bakta_db="resources/bakta_db/db-light/"` - the path to the _Bakta_ database used for gene annotation. This was already pre-downloaded for us. 

Our `samplesheet.csv` file looked as follows: 

```
sample,barcode
CTMA_1402,barcode01
CTMA_1421,barcode02
CTMA_1427,barcode05
CTMA_1432,barcode06
CTMA_1473,barcode09
```

We used the sample identifiers from the original publication, and their respective barcodes. 
If these were our own samples, we would have used identifiers that made sense to us. 

We then ran the script using `bash scripts/02-assembly.sh`.
The script prints a message while it's running: 

```
Processing sample 'CTMA_1402' with barcode 'barcode01'
        2023-08-09 22:41:38      Concatenating reads...
        2023-08-09 22:41:42      Subsampling reads with rasusa...
        2023-08-09 22:42:47      Assembling with flye...
        2023-08-09 22:55:37      Polishing with medaka...
        2023-08-09 22:59:41      Annotating with bakta...
        2023-08-09 23:24:47      Finished assembly pipeline for 'isolate01'.
                                 Assembly file in: results/assemblies/isolate01.fasta
                                 Annotation file in: results/assemblies/isolate01.gff

Processing sample 'CTMA_1421' with barcode 'barcode02'
        2023-08-09 23:24:47      Concatenating reads...
        2023-08-09 23:24:56      Subsampling reads with rasusa...
        2023-08-09 23:26:32      Assembling with flye...
        2023-08-09 23:52:36      Polishing with medaka...
```

This took a long time to run, it was around 5h for us. <i class="fa-solid fa-mug-hot"></i> <i class="fa-solid fa-mug-hot"></i> <i class="fa-solid fa-mug-hot"></i>
:::
:::

:::{.callout-exercise}
#### Looking for genes of interest

The _varG_ gene is part of the antibiotic resistance var regulon in _Vibrio cholerae_ ([source](https://card.mcmaster.ca/ontology/41453)). 

Using the command line tool `grep`, search for this gene in the annotation files produced by _Bakta_. 

:::{.callout-hint collapse=true}
- See @sec-bakta-annot for an example of how we did this for the _ctxA_ and _ctxB_ genes. 
- The pipeline script we used outputs the _Bakta_ results to `results/assemblies/04-bakta/SAMPLE/consensus.tsv` (where "SAMPLE" is the sample name).
- Remember that you can use the `*` wildcard to match multiple file/directory names
:::

:::{.callout-answer collapse=true}

To search for this gene across all our samples, we did: 

```bash
grep -i "varG" results/assemblies/04-bakta/*/consensus.tsv
```

```
results/assemblies/04-bakta/CTMA_1402/consensus.tsv:contig_2    cds     1452034 1453002 +       FHBCKO_14010    varG    VarG family subclass B1-like metallo-beta-lactamase     NCBIProtein:WP_000778180.1, SO:0001217, UniRef:UniRef50_A0A290TY11
results/assemblies/04-bakta/CTMA_1421/consensus.tsv:contig_4    cds     1469496 1470620 -       GBDILF_14250    varG    VarG family subclass B1-like metallo-beta-lactamase     NCBIProtein:WP_000778180.1, SO:0001217, UniRef:UniRef50_A0A290TY11
results/assemblies/04-bakta/CTMA_1427/consensus.tsv:contig_1    cds     1682677 1683801 -       CJLKCO_09705    varG    VarG family subclass B1-like metallo-beta-lactamase     NCBIProtein:WP_000778180.1, SO:0001217, UniRef:UniRef50_A0A290TY11
results/assemblies/04-bakta/CTMA_1432/consensus.tsv:contig_2    cds     1363185 1364309 +       BDJHLF_13895    varG    VarG family subclass B1-like metallo-beta-lactamase     NCBIProtein:WP_000778180.1, SO:0001217, UniRef:UniRef50_A0A290TY11
results/assemblies/04-bakta/CTMA_1473/consensus.tsv:contig_2    cds     1373351 1374475 +       DGGMCP_08610    varG    VarG family subclass B1-like metallo-beta-lactamase     NCBIProtein:WP_000778180.1, SO:0001217, UniRef:UniRef50_A0A290TY11
```

We can see that all 5 samples contain this gene. 
According to this [gene's description on CARD](https://card.mcmaster.ca/ontology/41453), this suggests that all of these isolates might be resistant to antimicrobial drugs using penicillins, carbapenems or cephalosporins.
:::
:::

## Summary

::: {.callout-tip}
#### Key Points

- _De novo_ genome assembly involves reconstructing a complete genome sequence without relying on a reference genome.
- Genome coverage refers to the average number of times each base in the genome is sequenced.
- Higher coverage provides more confident assembly, especially in repetitive regions, but it can be computationally intensive and expensive. Low coverage leads to more fragmented and less accurate assemblies.
- Key steps in Nanopore data assembly, along with relevant software, include:: 
  - Downsample reads using `rasusa` to optimize coverage, typically aiming for around 100-150x.
  - Assembly with `flye`, a tool specialised for long-read technologies.
  - Enhance accuracy through polishing with `medaka`, which corrects systematic ONT errors.
  - Annotate genomes using `bakta` to identify genes and other genome features.
- Automation scripts simplify assembly across multiple samples by executing the same commands for each, ensuring consistency and saving time.
- The provided script requires a samplesheet (CSV file) containing sample IDs and barcodes. Additionally, selecting the appropriate medaka error-correction model is crucial for accurate results.
:::
