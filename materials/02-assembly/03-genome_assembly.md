---
title: Genome assembly
---

::: {.callout-tip}
#### Learning Objectives

- Bulleted list of learning objectives
:::


## Genome Assembly

The next step in our bioinformatics analysis is to assemble a genome from our Nanopore sequencing reads. 
Genome assembly consists of identifying how the sequencing reads fit together to reconstruct the genome of the organism. 
In our case, we expect to reconstruct the genome sequences of the _Vibrio cholerae_ isolates we obtained, to later identify presence of toxigenic and/or antimicrobial resistance genes. 

There are different methods to assemble genomes, broadly falling in two categories: **de-novo assembly** and **reference-based consensus assembly**.  
The first method uses no prior information, attempting to reconstruct the genome from the sequencing reads only. 
This method is useful when we either don't know which organism(s) to expect, or if the organism we are working with is very diverse, so there is no single reference genome that is representative of the full diversity observed in the species. 
While de novo assembly is an unbiased way to reconstruct genomes, it is both computationally intense and challenging to achieve high-quality complete genomes, as it is often difficult to bridge gaps and repetitive regions.  

An alternative to de novo assembly is reference-based assembly, which generates an assembly by using a reference genome as a "scaffold". 
In this case, reads are aligned to the reference genome and used to generate a _consensus_ sequence based on the new mutations identified from the reads. 
This method is less computionally intense and can be used when we know which organism we're working with. 
The disadvantage of this method is that it doesn't work so well when our organism is very diverged from the reference (for example due to large genome rearrangments such as insertions, inversions and repeats). 

In our example study, we are working with cultured _V. cholerae_ samples. 
Although there are many [high-quality genomes available on NCBI](https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=666&annotated_only=true&refseq_annotation=true&typical_only=true), this species is notorious for having a plastic genome, with the presence of several mobile genetic elements and gene exchange happening through conjugation and phage-mediated transduction ([Montero et al. 2023](https://doi.org/10.3389/fmed.2023.1155751) and [Ramamurthy et al. 2019](https://doi.org/10.3389%2Ffpubh.2019.00203)). 
Therefore, a reference-based assembly may not be the most suited for this species, as we might miss important genes from our samples, if they are not present in the reference genome that we choose. 

As such, we will perform _de novo assembly_ of our genomes, starting from the basecalled FASTQ files. 
The general procedure is as follows: 

* Downsample the FASTQ files for a target depth of coverage of ~100x.
* Assemble the reads into contiguous fragments.
* "Polish" those fragments to correct systematic sequencing errors common in Nanopore data.
* Annotate the assembled fragments, by identifying the position of known bacterial genes.

In the following section we explain the step-by-step procedure for a single sample, but we later provide a script that performs all these steps automatically for several samples. 


## Step-by-step bacterial assembly

As we mentioned earlier, de novo assembly of genomes is a challenging process. 
Ideally, we want to achieve a "perfect genome", i.e. a complete representation of the individual's genome, with no errors and no missing gaps.
Although challenging, it is possible to achieve near-perfect genomes, in particular when multiple types of data are available: long reads for assembling more difficult regions and short reads for correcting the high error rates of long reads ([Wick et al. 2023](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1010905)). 

In this section, we introduce a simplified version of the tutorial "[Assembling the perfect bacterial genome](https://github.com/rrwick/Perfect-bacterial-genome-tutorial/wiki)", which is suitable for nanopore-only data. 


### Sampling: `rasusa`

The first step in our analysis is to sample a fraction of our original reads to match a minimum specified genome coverage. 
This may seem counterintuitive, as we may expect that more data is always better. 
While this is generally the case, it turns out that for genome assembly there is a plateau at which the tradeoff between having too much data doesn't outweight the computational costs that come with it. 
For example, assembling a _Vibrio_ genome with an average depth of coverage of 500x might take 5h, while one with 100x might take 1h, with very similar results in the final assembly. 
The computational burden is especially relevant when we are running analysis on a local computer, rather than on a HPC cluster (where we can run analysis in parallel), as each sample will have to be processed sequentially. 

Since we are running our analysis on a local computer, we will downsample our FASTQ reads to achieve a target depth of coverage of ~100x, using the software [_Rasusa_](https://github.com/mbhall88/rasusa). 
This software has been specifically designed to work with reads of different lengths (as is the case with ONT data), randomly sampling the reads to achieve an average coverage of a genome of a certain size (specified by the user). 
This sampling procedure takes the read lenghts into account, so for example if the average read length from the ONT run is longer then fewer reads will be needed than if the average read length is shorter (more reads are needed to cover the genome). 
As an example, let's say that our genome was estimated to be 1Mb (1 million bases) long and we wanted a target depth of coverage of 20x. 
If our reads were on average 1Kb long then we would need 10^6 / 10^3 * 20 = 200,000 reads, whereas if our reads were 10Kb long on average, then we would only need 2000 reads instead. 
This is a very simplified example, as our reads are not all the same length, but that's the general objective that _Rasusa_ is trying to achieve. 

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
In that case, `rasusa` instead keeps all the reads, with an appropriate message, for example: 

```
Requested coverage (100.00x) is not possible as the actual coverage is 37.27x - output will be the same as the input
```


### Assembly: `flye`

Now that we have downsampled our reads, we are ready for the next step of the analysis, which is the actual assembly. 
We perform this using the [_Flye_](https://github.com/fenderglass/Flye) software, although [many other assemblers](https://en.wikipedia.org/wiki/De_novo_sequence_assemblers) are available.

Continuing from our example `barcode26` sample, here is the `flye` command that we could use: 

```bash
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
00-assembly  10-consensus  20-repeat  30-contigger  40-polishing 
assembly.fasta  assembly.fasta.fai  assembly.fasta.map-ont.mmi  
assembly_graph.gfa  assembly_graph.gv  assembly_info.txt  flye.log  params.json
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

We can see for our example run that we have a total assembly length of ~4.2 Mb, which matches our expected genome size very well. 
The number of final fragments was 3, and given that _Vibrio cholerae_ has 2 chromosomes, this is not bad at all - we must have been able to assembly the two chromosomes nearly completely. 
The largest fragment is ~3 Mb, which again from our knowledge of other _Vibrio_ genomes, probably corresponds to chromosome 1. 
And we can see the final depth of coverage of the genome is 98x, which makes sense, since we sampled our reads to achieve ~100x. 

Sometimes you may end up with more fragmented genome assemblies, in particular if your coverage is not as good. 
For the example we showed earlier, where `rasusa` reported our reads were only enough for ~37x coverage, our flye assembly resulted in more than 30 fragments. 
While this is worse than a near-complete assembly, it doesn't mean that the genome assembly is useless. 
We should still have recovered a lot of the genes, and even a fragmented assembly can be used to identify sequence types and pathogenic and AMR genes. 


### Polishing: `medaka`

As we mentioned earlier, ONT reads typically has higher error rates compared to other technologies such as short-read Illumina sequencing (often achieving << 1% error). 
Even the latest chemistry still has error rates of ~5%, which is substantial and may cause the wrong base to be present in our final assembly. 
Although `flye` tries to correct some of these mistakes, that is not its main focus (its main focus is to "stich" our reads together into a contiguous sequence). 
Therefore, as an additional step after assembly, we can go through the FASTA file of our assembly and correct any potential errors that may have been kept from the original reads, often referred to as **polishing** our assembly. 

Polishing can be done using the _Medaka_ software developed by ONT.
In particular, the tool `medaka_consensus`, which was specifically designed to work with genome assemblies from _Flye_. 
The procedure consists of aligning the original reads to the newly assembled genome, and then identifying what the correct base at each position of the genome should be, based on the "pileup" of reads aligning to that position. 
This is done using a machine learning model trained on ONT data, which therefore accounts for specific error patterns and biases in these type of data. 

Continuing from our example for `barcode26` / `isolate2`, we would run the following: 

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
This process is called genome annotation, and for bacterial genomes we can do this using the software [_Bakta_](https://github.com/oschwengers/bakta). 
This software takes advantage of the huge number of available bacterial gene sequences in public databases, to aid in the identification of genes in our new assembly.
_Bakta_ achieves this by looking for regions of our genome that have high similarity with those public sequences. 

In order to run `bakta` we first need to download the database that it will use to aid the annotation. 
This can be done with the `bakta_db` command. 
There are two versions of its database: "light" and "full". 
The "light" database is smaller and results in a faster annotation runtime, at the cost of a less accurate/complete annotation. 
The "full" database is the recommended for the best possible annotation, but it is much larger and requires longer runtimes. 

For the purposes of our tutorial, we will use the "light" database, but if you were running this through your own samples, it may be desirable to use the "full" database. 
To download the database you can run (if you are attending our workshop, please don't run this step, as we already did this for you):

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

The main file we will need is `bakta.db`, which we use in our next step.

:::{.callout-important}
You only need to download the `bakta` database once, and it may be a good idea to save it in a separate folder that you can use again for a new analysis. 
This should save you substantial time and storage space. 
:::

To run the annotation we use the `bakta` command, continuing with our example of `barcode26` / `isolate2`:

```bash
bakta --db resources/bakta_db/db-light/bakta.db --output results/bakta/isolate2 --threads 8 results/medaka/isolate2/consensus.fasta
```

- `--db` is the path to the database file we downloaded above.
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
The main file of interest is `consensus.gff3`, which we will use in a later chapter about [phylogenetic analysis](../03-typing/03-phylogeny.md). 
The tab-delimited file `consensus.tsv` is convenient as it can be opened in a spreadsheet program such as _Excel_. 

Using the command line tool `grep`, we can quickly search for genes of interest. 
For example, we can see if the genes from the CT phage (CTX) are present in your samples (these include the toxin-encoding genes _ctxA_ and _ctxB_):

```bash
grep -i "ctx" results/bakta/isolate2/consensus.tsv
```

```
contig_2        cds     2236513 2237289 +       LBGGEL_19385    ctxA    cholera enterotoxin catalytic subunit CtxA      BlastRules:WP_001881225, NCBIProtein:AAF94614.1
contig_2        cds     2237286 2237660 +       LBGGEL_19390    ctxB    cholera enterotoxin binding subunit CtxB        BlastRules:WP_000593522, NCBIProtein:AAF94613.1, SO:0001217, UniRef:UniRef50_P01556
```

Both subunits are found in our assembly, suggesting our isolate is a pathogenic strain of _Vibrio cholerae_. 

And this concludes our assembly workflow: we now have an **annotated genome assembly** produced from our ONT reads. 


## Assembly workflow

In the previous section we applied our assembly workflow to a single sample. 
But what if we had 20 samples? 
It would be quite tedious and error-prone to have to copy/paste and modify these commands so many times. 

Instead, we can automate our analysis using some programming techniques, such as a _for loop_, to repeat the analysis across a range of samples. 
This is what we've done for you, having already prepared a shell script that runs through these steps sequentially for any number of samples (the script is available here). 
Our script is composed of two parts: 

- At the top of the script you will find a section called `#### Settings ####`, where you can define several options to run the analysis (we will detail these below).
- Another section is called `#### Assembly pipeline ####` and that is where the code to run the analysis we detailed step-by-step earlier is done. 
  You can have a look at the code, but be careful making any changes here (as we use more advanced shell programming techniques).
  
We have the following settings available: 

- `--samplesheet` → the path to a CSV file with at least two columns:  
  - `sample` - sample name of your choice for each barcode; for example "isolate1", "isolate2", etc.
  - `barcode` - barcode folder names of each samples; this should essentially match the folder names in the `fastq_pass` folder output by the _Guppy_ basecaller, for example "barcode01", "barcode02", "barcode34", etc. 
  - you can include other columns in this sheet (such as metadata information), as long as the first two columns are the ones explained above.
- `--fastq_dir` → the path to the directory where the FASTQ files are in. The pipeline expects to find individual barcode folders within this, so we use the `fastq_pass` directory generated by the _Guppy_ basecaller. 
- `--outdir` → the path to the output directory where all the results files will be saved.
- `--threads` → how many CPUs are available for parallel processing. 
- `--genome_size` → the predicted genome size for the bacterial we are assembling (4m is recommended for _Vibrio_).
- `--coverage` → the desired coverage for subsampling our reads to.
- `--medaka_model` → the medaka model to use for the polishing step (as explained above). 
- `--bakta_db` → the path to the `bakta` database file.

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

In this example, we have 10 isolates (number 1 to 10), corresponding to different barcodes. 
The samplesheet therefore makes the correspondence between each sample's name and its respective barcode folder. 

One we have this samplesheet and we edit all the options in the script, we can run the script using `bash`: 

```bash
bash scripts/02-assembly.sh
```

Our script in this case was called `02-assembly.sh` and we had saved it in a folder called `scripts`. 
Note that all the file paths specified in the "Settings" of the script are relative to the folder where we run the script from. 
In our case, we had a folder named `awd_workshop`, where we are running the analysis from, and that is where we ran the script from. 

The script will take quite a while to run (around 1h per sample using 16 CPUs on our computers), so you may have to leave your computer doing the hard work overnight. 
As it runs, the script prints some progress messages on the screen: 

```
Starting sample 'isolate01' with barcode 'barcode25'...
  Subsampling reads with rasusa...
  Assembling with flye...
  Polishing with medaka...
  Annotating with bakta...
  Finished assembly pipeline for 'isolate01'.
  Assembly file in: results/assemblies/isolate01.fasta
  Annotation file in: results/assemblies/isolate01.gff
Starting sample 'isolate02' with barcode 'barcode26'...
  Subsampling reads with rasusa...
  Assembling with flye...
```

Also, it starts producing several output files in the directory you specified. 
For example, in our case, at the end of the run we have: 

```bash
ls results/assemblies
```

```
01-rasusa  04-bakta         isolate02.fasta  isolate03.gff    isolate05.fasta  isolate06.gff    isolate08.fasta
02-flye    isolate01.fasta  isolate02.gff    isolate04.fasta  isolate05.gff    isolate07.fasta  isolate09.fasta
03-medaka  isolate01.gff    isolate03.fasta  isolate04.gff    isolate06.fasta  isolate07.gff    isolate10.fasta
```

We get a folder with the results of each step of the analysis (this matches what we went through in detail in the step-by-step section) and two files per sample: a FASTA file with the polished assembly and a GFF file with the gene annotations. 

:::{.callout-note}
#### Command line tricks for QC

Earlier we saw that the _Flye_ assembler outputs some statistics of interest in a `flye.log` file, such as the average coverage of the assembly. 
We could look at each file from our samples indivually, but that would be very repetitive. 
Instead, we can use some command line trics to achieve this, namely using the `grep` command together with the `*` wildcard: 

```bash
grep "Mean coverage:" results/assemblies/02-flye/*/flye.log
```

```
results/assemblies/02-flye/isolate01/flye.log:  Mean coverage:  31
results/assemblies/02-flye/isolate02/flye.log:  Mean coverage:  98
results/assemblies/02-flye/isolate03/flye.log:  Mean coverage:  100
results/assemblies/02-flye/isolate04/flye.log:  Mean coverage:  98
results/assemblies/02-flye/isolate05/flye.log:  Mean coverage:  21
results/assemblies/02-flye/isolate06/flye.log:  Mean coverage:  44
results/assemblies/02-flye/isolate07/flye.log:  Mean coverage:  40
results/assemblies/02-flye/isolate08/flye.log:  Mean coverage:  43
results/assemblies/02-flye/isolate09/flye.log:  Mean coverage:  22
results/assemblies/02-flye/isolate10/flye.log:  Mean coverage:  48
```

In one command we get the mean coverage for all our 10 samples - great!

How about the number of fragments? 

```bash
grep "Fragments:" results/assemblies/02-flye/*/flye.log
```

```
results/assemblies/02-flye/isolate01/flye.log:  Fragments:      37
results/assemblies/02-flye/isolate02/flye.log:  Fragments:      3
results/assemblies/02-flye/isolate03/flye.log:  Fragments:      2
results/assemblies/02-flye/isolate04/flye.log:  Fragments:      3
results/assemblies/02-flye/isolate05/flye.log:  Fragments:      236
results/assemblies/02-flye/isolate06/flye.log:  Fragments:      52
results/assemblies/02-flye/isolate07/flye.log:  Fragments:      51
results/assemblies/02-flye/isolate08/flye.log:  Fragments:      22
results/assemblies/02-flye/isolate09/flye.log:  Fragments:      121
results/assemblies/02-flye/isolate10/flye.log:  Fragments:      3
```

Wow, we can see that some of our assemblies are very fragmented - isolate05 has 236 fragments!
Can you see why this might be the case?
:::


## Exercises

:::{.callout-exercise}
#### Running assembly script

TODO

:::


## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
