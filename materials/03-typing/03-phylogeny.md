---
title: Building phylogenetic trees
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::


## Pathogen Phylogenetics

Phylogenetic analysis aims to determine evolutionary relationships among organisms. 
In the context of pathogenic organisms, it is used to study the origin of human-infecting strains. 
This involves analyzing sequences from various bacterial/viral species infecting humans and other species. 
For instance, during the COVID-19 pandemic, inter-species phylogeny was used to [trace the origin of the SARS-CoV-2 virus](https://doi.org/10.1007/s10311-020-01151-1) that adapted to infect humans.

Pathogen surveillance mostly focuses on intra-species phylogenies. 
Here, phylogenies are constructed from sequences within the same pathogenic species. 
The objective is to understand how specific strains and lineages relate and evolve. 
By analyzing genetic differences, we can track pathogen spread and identify outbreak sources. 
This section aims to answer: **how do our Vibrio cholerae isolates relate to each other and to previously sequenced strains?**
This sheds light on relationships among isolates and their evolutionary context.

To construct a phylogeny, two primary steps are necessary:

- **Multiple sequence alignment:** to account for variations in sequence lengths due to insertions/deletions, aligning homologous residues of each sequence is the first step.
- **Tree inference:** with the aligned sequences, statistical models of sequence evolution are used to infer the most probable relationship between these sequences, based on observed substitutions.

Multiple sequence alignment is straightforward when dealing with a single gene or closely related species (e.g. clonal bacterial species). 
However, bacterial species can exhibit substantial differences due to factors like horizontal gene transfer (e.g. through conjugation or bacteriophages), gene duplication, and gene loss. 
In such cases, alignment focuses on the **core genome**, the gene set present in most species members, enabling inference of evolutionary relationships. 
This contrasts with the "accessory genome," consisting of genes present only in some members of the species. 
The complete collection of core and accessory genomes in a species is referred to as the **pangenome**.

Given the diversity of _Vibrio cholerae_, which often acquires resistance genes through horizontal transfer, the phylogenetic process begins with generating a **core genome alignment**, forming the foundation for tree inference. 
We will explore phylogenetic analysis of _Vibrio cholerae_ using _Pathogenwatch_, followed by a guide to constructing your own phylogenies using command line tools.


## Phylogenies with Pathogenwatch {#sec-phylo-pathogenwatch}

In the "collection view" screen for your samples, _Pathogenwatch_ shows you a phylogenetic tree on the top-left panel, showing the relationship between the sequences in your collection. 
This shows how tightly our samples cluster with each other, and outliers may indicate assembly issues. 
For example, we can see from @fig-phylo-pathogenwatch1 that "isolate05" clusters separately from the rest of the samples. 
From our [previous analysis of assembly quality](../02-assembly/04-assembly_quality.md) we saw that this sample had poorer sequencing coverage, which may have led to a higher error rate (because fewer sequencing reads were available to identify a consensus sequence). 

![Phylogenetic view of the samples in our collection. You can view the sample names by clicking on the buttons shown.](images/phylo_pathogenwatch01.svg){#fig-phylo-pathogenwatch1}

We can also show how your samples relate to the "reference genomes" available in _Pathogenwatch_ (@fig-phylo-pathogenwatch2).
These are genomes curated by the [_Vibriowatch_ project](https://genomic-surveillance-for-vibrio-cholerae-using-vibriowatch.readthedocs.io/en/latest/mlst.html#compare-your-isolate-to-vibriowatch-s-reference-genomes), which include several genomes that have been assigned to different phylogenetic lineages, and associated with transmission waves/events.

![Phylogenetic view of the "Population" samples used in the default phylogenetic analysis from _Pathogenwatch_. You can choose this view from the top-left dropdown menu as illustrated. The clades on which your samples were clustered with appear in purple.](images/phylo_pathogenwatch02.png){#fig-phylo-pathogenwatch2}

In @fig-phylo-pathogenwatch2 we can see that all our 10 samples fall in the "W3_T13" clade (wave 3, transmission event 13). 
This reference clade corresponds to strains from the most recent transmission wave in Africa determined by [Weill et al. 2017](https://doi.org/10.1126/science.aad5901). 
This agrees with other pieces of evidence we aquired so far, that our strains are closely related to the most recent pathogenic strains circulating worldwide. 

You can further "zoom in" on the tree to see how your samples relate to the reference samples present in this clade (@fig-phylo-pathogenwatch3). 
This shows that although our samples are related to "W3 T3" reference samples, they have accumulated enough mutations that makes them cluster apart from the reference panel. 
Note that some of the lineage classification used by _Pathogenwatch_ may be slightly outdated, as new strains emerge that were not part of the 2017 study mentioned above. 

![Clicking on the "W3_T13" clade shows our samples in the context of the other reference genomes in this clade.](images/phylo_pathogenwatch03.png){#fig-phylo-pathogenwatch3}

:::{.callout-important}
#### Sequence divergence or sequencing error?

Phylogenetic analysis is also useful to assess our assembly quality with regards to **validity/correctness** of our sequences. 
If our sequences are very diverged from other sequences (i.e. several mutations separate them from other sequences), this may indicate a high error rate in our assemblies. 
However, this is not always easy to assess, as the public collection such as the one from _Pathogenwatch_ (@fig-phylo-pathogenwatch3) may have older sequences, so this may represent true divergence since the time those samples were collected. 

To fully address if our samples likely have sequencing errors, we can do any of the following: 

* Compare your samples with similar (or even the same) samples assembled with higher accuracy data. 
  For example, following the advice given on the "[perfect bacterial genome](https://github.com/rrwick/Perfect-bacterial-genome-tutorial/wiki)" pipeline (using a "hybrid assembly" approach with both Illumina and ONT data). 
* Using more recent ONT chemistry, flowcells and basecalling software, which [provide higher accuracy sequences](https://nanoporetech.com/accuracy).
* Compare our assemblies with recent samples from the same region/outbreak.
:::


## Phylogenies with local software

In the previous section we used _Pathogenwatch_ to perform a phylogenetic analysis, using its inbuilt collection. 
While _Pathogenwatch_ is user-friendly, it relies on a web-based service that might not always be accessible. 
Therefore, we introduce an alternative using command line tools suitable for local execution on your computer.
The methodology we use here is similar to _Pathogenwatch_'s, but it employs distinct tools for generating the core genome and performing tree inference. 
Our toolkit consists of three software components:

- **[Panaroo](https://gtonkinhill.github.io/panaroo/#/gettingstarted/quickstart)** - used to identify a set of "core genes" (genes occurring in most samples) and generate a multiple sequence alignment from them.
- **[SNP-sites](http://sanger-pathogens.github.io/snp-sites/)** - used to extract variable sites from the alignment (to save computational time). 
- **[IQ-TREE](http://www.iqtree.org/doc/)** - used to infer a tree from the aligned core genes.
- **[Figtree](http://tree.bio.ed.ac.uk/software/figtree/)** - used to visualise and/or annotate our tree.


### Core genome alignment: `panaroo` {#sec-panaroo}

The software [_Panaroo_](https://gtonkinhill.github.io/panaroo/) was developed to analyse bacterial pangenomes. 
It is able to identify orthologous sequences between a set of sequences, which it uses to produce a multiple sequence alignment of the core genome. 
The output alignment it produces can then be used to build our phylogenetic trees in the next step.

As input to _Panaroo_ we will use: 

- The gene annotations for our newly assembled genomes, which were produced during the [assembly pipeline](../02-assembly/03-genome_assembly.md) using _Bakta_. 
- Annotations from 31 public genomes downloaded from NCBI (see @sec-public-genomes). 
  These annotations had to be processed to be compatible with _Panaroo_, which we detail in the information box below. 

To run _Panaroo_ on our samples we can use the following commands:

```bash
# create output directory
mkdir results/panaroo

# run panaroo
panaroo \
  --input results/assemblies/*.gff resources/vibrio_genomes/*.gff \
  --out_dir results/panaroo \
  --clean-mode strict \
  --alignment core \
  --core_threshold 0.98 \
  --remove-invalid-genes \
  --threads 8
```

The options used are: 

- `--input` - all the input annotation files, in the _Panaroo_-compatible GFF format. Notice how we used the `*` wildcard to match all the files in each folder: the `results/assemblies` folder contains the annotations for our own genomes; the `resources/vibrio_genomes/` folder contains the public annotations (suitably converted to _Panaroo_-compatible format - see information box below). 
- `--out_dir` - the output directory we want to save the results into.
- `--clean-mode` - determines the stringency of _Panaroo_ in including genes within its pangenome graph for gene clustering and core gene identification. The available modes are 'strict', 'moderate', and 'sensitive'. These modes balance eliminating probable contaminants against preserving valid annotations like infrequent plasmids. In our case we used 'strict' mode, as we are interested in building a core gene alignment for phylogenetics, so including rare plasmids is less important for our downstream task.
- `--alignment` - whether we want to produce an alignment of core genes or all genes (pangenome alignment). In our case we want to only consider the core genes, to build a phylogeny.
- `--core_threshold` - the fraction of input genomes where a gene has to be found to be considered a "core gene". In our case we've set this to a very high value, to ensure most of our samples have the gene.
- `--remove-invalid-genes` - this is recommended to remove annotations that are incompatible with the annotation format expected by _Panaroo_. 
- `--threads` - how many CPUs we want to use for parallel computations.

_Panaroo_ takes a long time to run, so be prepared to wait a while for its analysis to finish <i class="fa-solid fa-mug-hot"></i>. 

Once if finishes, we can see the output it produces:

```bash
ls results/panaroo
```

```
aligned_gene_sequences/                core_alignment_header.embl        gene_presence_absence_roary.csv
alignment_entropy.csv                 core_gene_alignment.aln           pan_genome_reference.fa
combined_DNA_CDS.fasta                core_gene_alignment_filtered.aln  pre_filt_graph.gml
combined_protein_CDS.fasta            final_graph.gml                   struct_presence_absence.Rtab
combined_protein_cdhit_out.txt        gene_data.csv                     summary_statistics.txt
combined_protein_cdhit_out.txt.clstr  gene_presence_absence.Rtab
core_alignment_filtered_header.embl   gene_presence_absence.csv
```

There are several output files generated, which can be generated for more advanced analysis and visualisation (see [_Panaroo_ documentation](https://gtonkinhill.github.io/panaroo/#/gettingstarted/quickstart) for details). 
For our purpose of creating a phylogeny from the core genome alignment, we need the file `core_gene_alignment.aln`, which is a file in FASTA format. 
We can take a quick look at this file: 

```bash
head results/panaroo/core_gene_alignment.aln
```

```
>GCF_015482825.1_ASM1548282v1_genomic
atggctatttatctgactgaattatcgccggaaacgttgacattcccctctccttttact
gcgttagatgaccctaacggcctgcttgcatttggcggcgatctccgtcttgaacgaatt
tgggcggcttatcaacaaggcattttcccttggtatggccctgaagacccgattttgtgg
tggagcccttccccacgtgccgtgtttgaccctactcggtttcaacctgcc-aaaagcgt
gaagaagttccaacgtaaacatcagtatcgggttagcgtcaatcacgcgacgtcgcaagt
gattgagcagtgcgcgctcactcgccctgcggatcaacgttggctcaatgactcaatgcg
ccatgcgtatggcgagttggcgaaacaaggtcgttgccattctgttgaggtgtggcaggg
cgaacaactggtgggtgggctttatggcatttccgttggccaactgttttgtggcgaatc
catgtttagcctcgcaaccaatgcctcgaaaattgcgctttggta-tttttgcgaccatt
```

We can see this contains a sequence named "GCF_015482825.1_ASM1548282v1_genomic", which corresponds to one of the NCBI genomes we downloaded. 
We can look at all the sequence names in the FASTA file: 

```bash
grep ">" results/panaroo/core_gene_alignment.aln
```

```
>GCF_015482825.1_ASM1548282v1_genomic
>GCF_019704235.1_ASM1970423v1_genomic
>GCF_013357625.1_ASM1335762v1_genomic
>GCF_017948285.1_ASM1794828v1_genomic
>GCF_009763825.1_ASM976382v1_genomic
>isolate01
>GCF_013357665.1_ASM1335766v1_genomic
>GCF_009762915.1_ASM976291v1_genomic
>GCF_009762985.1_ASM976298v1_genomic

... more output omitted to save space ...
```

We can see each input genome appears once, including the "isolateXX" genomes assembled and annotated by us.

:::{.callout-note collapse=true}
#### Preparing GFF files for _Panaroo_ (click to see details)

_Panaroo_ requires GFF files in a non-standard format. 
They are similar to standard GFF files, but they also include the genome sequence itself at the end of the file. 
By default, _Bakta_ (which we used [earlier](../02-assembly/03-genome_assembly.md) to annotate our assembled genomes) already produces files in this non-standard GFF format. 

However, GFF files downloaded from NCBI will not be in this non-standard format. 
To convert the files to the required format, the _Panaroo_ developers provide us with a [Python script](https://raw.githubusercontent.com/gtonkinhill/panaroo/master/scripts/convert_refseq_to_prokka_gff.py) that can do this conversion: 

```bash
python3 convert_refseq_to_prokka_gff.py -g annotation.gff -f genome.fna -o new.gff
```

- `-g` is the original GFF (for example downloaded from NCBI).
- `-f` is the corresponding FASTA file with the genome (also downloaded from NCBI).
- `-o` is the name for the output file.

This is a bit more advanced, and is included here for interested users. 
We already prepared all the files for performing a phylogeny, so you don't need to worry about this for the workshop. 
:::


### Extracting variable sites: `snp-sites`

Although you could use the alignment generated by _Panaroo_ directly as input to _IQ-TREE_, this would be quite computationally heavy, because the core genome alignments tend to be quite big. 
Instead, what we can do is **extract the variable sites** from the alignment, such that we reduce our FASTA file to only include those positions that are variable across samples. 

Here is a small example illustrating what we are doing. 
For example, take the following three sequences, where we see 3 variable sites (indicated with an arrow):

```
seq1  C G T A G C T G G T
seq2  C T T A G C A G G T
seq3  C T T A G C A G A T
        ↑         ↑   ↑
```

For the purposes of phylogenetic tree construction, we only use the variable sites to look at the relationship between our sequences, so we can simplify our alignment by extract only the variable sites:

```
seq1  G T G
seq2  T A G
seq3  T A A
```

This example is very small, but when you have a 4Mb genome, this can make a big difference. 
To extract variable sites from an alignment we can use the _SNP-sites_ software: 

```bash
# create output directory
mkdir results/snp-sites

# run SNP-sites
snp-sites results/panaroo/core_gene_alignment.aln > results/snp-sites/core_gene_alignment_snps.aln
```

This command simply takes as input the alignment FASTA file and produces a new file with only the variable sites - which we redirect (`>`) to an output file. 
This is the file we will use as input to constructing our tree.

However, before we move on to that step, we need another piece of information: the **number of constant sites** in the initial alignment (sites that didn't change). 
Phylogenetically, it makes a difference if we have 3 mutations in 10 sites (30% variable sites, as in our small example above) or 3 mutations in 1000 sites (0.3% mutations). 
The _IQ-TREE_ software we will use for tree inference can accept as input 4 numbers, counting the number of A, C, G and T that were constant in the alignment. 
For our small example these would be, respectively: 1, 2, 2, 2.

Fortunately, the `snp-sites` command can also produce these numbers for us (you can check this in the help page by running `snp-sites -h`). 
This is how you would do this: 

```bash
# count invariant sites
snp-sites -C results/panaroo/core_gene_alignment.aln > results/snp-sites/constant_sites.txt
```

The key difference is that we use the `-C` option, which produces these numbers. 
Again, we redirect (`>`) the output to a file. 

We can see what these numbers are by printing the content of the file: 

```bash
cat results/snp-sites/constant_sites.txt
```

```
635254,561931,623994,624125
```

As we said earlier, these numbers represent the number of A, C, G, T that were constant in our original alignment. 
We will use these numbers in the tree inference step detailed next. 


### Tree inference: `iqtree` {#sec-iqtree}

There are different methods for inferring phylogenetic trees from sequence alignments. 
Regardless of the method used, the objective is to construct a tree that represents the evolutionary relationships between different species or genetic sequences.
Here, we will use the _IQ-TREE_ software, which implements **maximum likelihood methods of tree inference**.
Phylogenetic tree inference using maximum likelihood is done by identifying the tree that maximizes the likelihood of observing the given DNA sequences under a chosen evolutionary model.

In this process, **DNA substitution models** describe how DNA sequences change over time due to mutations. 
These models consider how frequently different bases (A, T, C, G) are replaced by each other. 
Another parameter these models can include is **rate heterogeneity**, which accounts for the fact that different DNA sites may evolve at different rates. 
Some sites might change rapidly, while others remain more stable.

Maximum likelihood aims to find the tree topology and branch lengths that make the observed DNA sequences most probable, given the chosen model. 
It does this by exploring various tree shapes and lengths to calculate the likelihood of the observed sequences. 
The tree with the highest likelihood is considered the best representation of the evolutionary relationships among the sequences. 
The process involves making educated guesses about the tree's parameters, calculating the likelihood of the data under these guesses, and refining the parameters iteratively to find the optimal tree that best explains the observed genetic variations.

_IQ-TREE_ offers various sequence evolution models, allowing researchers to match their analyses to different types of data and research questions.
Conveniently, this software can identify the most fitting substituion model for a dataset (using a tool called [_ModelFinder_](https://www.nature.com/articles/nmeth.4285)), while considering the complexity of each model.

We run _IQ-TREE_ on the output from _SNP-sites_, i.e. using the variable sites extracted from the core genome alignment:

```bash
# create output directory
mkdir results/iqtree

# run iqtree2
iqtree -s results/snp-sites/core_gene_alignment_snps.aln -fconst 635254,561931,623994,624125 --prefix results/iqtree/awd -nt AUTO -m GTR+F+I
```

The options used are: 

- `-s` - the input alignment file, in our case using only the variable sites extracted with `snp-sites`.
- `--prefix` - the name of the output files. This will be used to name all the files with a "prefix". In this case we are using the "awd" prefix, which is very generic. In your own analysis you may want to use a more specific prefix (for example, the name of the collection batch). 
- `-fconst` - these are the counts of invariant sites we estimated in the previous step with `snp-sites` (see previous section).
- `-nt AUTO` - automatically detect how many CPUs are available on the computer for parallel processing (quicker to run).
- `-m` - specifies the DNA substitution model we'd like to use. We give more details about this option below. 

When not specifying the `-m` option, `iqtree` employs _ModelFinder_ to pinpoint the substitution model that best maximizes the data's likelihood, as previously mentioned. 
Nevertheless, this can be time-consuming (as `iqtree` needs to fit trees numerous times). 
An alternative approach is utilizing a versatile model, like the one chosen here, "GTR+F+I," which is a [generalized time reversible (GTR) substitution model](https://en.wikipedia.org/wiki/Substitution_model#Generalised_time_reversible). 
This model requires an estimate of the base frequencies within the sample population, determined in this instance by tallying the base frequencies from the alignment (indicated by "+F" in the model name). 
Lastly, the model accommodates variations in rates across sites, including a portion of invariant sites (noted by "+I" in the model name).

We can look at the output folder: 

```bash
ls results/iqtree
```

```
awd.bionj  awd.ckp.gz  awd.iqtree  awd.log  awd.mldist  awd.model.gz  awd.treefile
```

There are several files with the following extension: 

- `.iqtree` - a text file containing a report of the IQ-Tree run, including a representation of the tree in text format.
- `.treefile` - the estimated tree in NEWICK format. We can use this file with other programs, such as _FigTree_, to visualise our tree. 
- `.log` - the log file containing the messages that were also printed on the screen. 
- `.bionj` - the initial tree estimated by neighbour joining (NEWICK format).
- `.mldist` - the maximum likelihood distances between every pair of sequences.
- `.ckp.gz` - this is a "checkpoint" file, which IQ-Tree uses to resume a run in case it was interrupted (e.g. if you are estimating very large trees and your job fails half-way through).
- `.model.gz` - this is also a "checkpoint" file for the model testing step. 

The main files of interest are the report file (`.iqtree`) and the tree file (`.treefile`) in standard [Newick format](https://en.wikipedia.org/wiki/Newick_format).


### Visualising trees: FigTree

There are many programs that can be used to visualise phylogenetic trees. 
In this course we will use _FigTree_, which has a simple graphical user interface.
You can open _FigTree_ from the terminal by running the command `figtree`. 

To open the tree: 

- Go to <kbd><kbd>File</kbd> > <kbd>Open...</kbd></kbd> and browse to the folder with the _IQ-TREE_ output files. 
- Select the file with `.treefile` extension and click <kbd>Open</kbd>.
- You will be presented with a visual representation of the tree. 

We can also import a "tab-separated values" (TSV) file with annotations to add to the tree, if you have any available (e.g. country of origin, date of collection, etc.). 
To add annotations:

- Go to <kbd><kbd>File</kbd> > <kbd>Import annotations...</kbd></kbd> and open the annotation file. This file has to be in tab-delimited format.
- On the menu on the left, click <kbd>Tip Labels</kbd> and under "Display" choose one of the fields of our metadata table. 

There are many ways to further configure the tree, including highlighting clades in the tree, and change the labels. 
See the @fig-phylo-figtree for an example. 

![Annotated phylogenetic tree obtained with _FigTree_. We identified a clade in the tree that corresponded to our samples, and used the "Highlight" function to give them a distinct colour (pink). We also highlighted the broader clade they are in (purple), which is composed of O1 biotype strains. To do this, change the "Selection Mode" at the top to "Clade", then select the branch at the base of the clade you want to highlight, and press the "Highlight" button on the top to pick a colour.](images/phylo_figtree.png){#fig-phylo-figtree}


## Exercises

<i class="fa-solid fa-triangle-exclamation" style="color: #1e3050;"></i> 
For these exercises, you can either use the dataset we provide in [**Data & Setup**](../../setup.md), or your own data. 
You also need to have completed the genome assembly exercise in @sec-ex-assembly.

:::{.callout-exercise}
#### Pathogenwatch phylogeny

Following from the _Pathogenwatch_ exercise in @sec-ex-pathogenwatch, open the "Ambroise 2023" collection that you created and answer the following questions:

- Does any of your sequences look like an outlier (i.e. a very long branch) in the sample tree view?
- Change the tree view to "Population". Which transmission wave do your samples cluster with?
- Looking within the population(s) where your samples cluster in, do your samples cluster together or are they interspersed between other samples from the _Pathogenwatch_ collection?

:::{.callout-answer collapse=true}

Looking at our samples' tree doesn't reveal any sample as a particular outlier. 

Looking at the "Population" view (from the dropdown on the top-left, as shown below), we can see that all of the "Ambroise 2023" samples fall within the "W3_T10" clade. 
This is a recent transmission wave, confirming our strains are pathogenic and related to other recent strains ([Weill et al. 2017](https://doi.org/10.1126/science.aad5901)). 

![](images/phylo_pathogenwatch_ambroise01.png)

Looking inside the clade, we can see that our samples cluster somewhat apart from the rest, suggesting they are more similar to each other than they are with the samples from the _Pathogenwatch_ collection. 
This might be because our samples are from 2023, whereas the collection from _Pathogenwatch_ is from 2017, so it is likely that these strains have accumulated new mutations since then.

![](images/phylo_pathogenwatch_ambroise02.png)

Note that in the image above we changed our tree layout to a "circle". Sometimes this view is helpful when we have too many sequences. 
:::
:::

:::{.callout-exercise}
#### Core genome alignment

Using _Panaroo_, perform a core genome alignment for your assembled sequences together with the public genomes we provide in `resources/vibrio_genomes/`. 

- Activate the software environment: `mamba activate typing`.
- Fix the script we provide in `scripts/05-panaroo.sh`. See @sec-panaroo if you need a hint of how to fix the code in the script.
- Run the script using `bash scripts/05-panaroo.sh`.

When the analysis starts you will get several messages and progress bars print on the screen.

<i class="fa-solid fa-triangle-exclamation" style="color: #1e3050;"></i>
This analysis takes a long time to run (several hours), so you can leave it running, open a new terminal and continue to the next exercise. 

:::{.callout-answer collapse=true}

The fixed code for our script is:

```bash
#!/bin/bash

# create output directory
mkdir -p results/panaroo/

# Run panaroo
panaroo \
  --input results/assemblies/*.gff resources/vibrio_genomes/*.gff \
  --out_dir results/panaroo \
  --clean-mode strict \
  --alignment core \
  --core_threshold 0.98 \
  --remove-invalid-genes \
  --threads 8
```

We have specified two sets of input files:

- `results/assemblies/*.gff` specifies all the GFF annotation files for our assembled genomes.
- `resources/vibrio_genomes/*.gff` specifies the GFF annotation files for the public genomes downloaded from NCBI. 

In both cases we use the `*` wildcard to match all the files with `.gff` extension. 

As it runs, _Panaroo_ prints several messages to the screen. 
The analysis took 7h to run on our computers! 
It's quite a long time, so it is advisable to run it on a high performance computing cluster, if you have one available. 
Otherwise, you will have to leave it running on your computer overnight. 

Once it finishes, we can see several output files: 

```bash
ls results/panaroo
```

```
aligned_gene_sequences                core_alignment_header.embl        gene_presence_absence_roary.csv
alignment_entropy.csv                 core_gene_alignment.aln           pan_genome_reference.fa
combined_DNA_CDS.fasta                core_gene_alignment_filtered.aln  pre_filt_graph.gml
combined_protein_CDS.fasta            final_graph.gml                   struct_presence_absence.Rtab
combined_protein_cdhit_out.txt        gene_data.csv                     summary_statistics.txt
combined_protein_cdhit_out.txt.clstr  gene_presence_absence.Rtab
core_alignment_filtered_header.embl   gene_presence_absence.csv
```

The main file of interest is `core_gene_alignment_filtered.aln`, which we will use for tree inference in the next exercise.

:::
:::

:::{.callout-exercise}
#### Tree inference

<i class="fa-solid fa-triangle-exclamation"></i> 
Because _Panaroo_ takes a long time to run, we provide pre-processed results in the folder `preprocessed/`, which you can use as input to IQ-TREE in this exercise.

Produce a tree from the core genome alignment from the previous step. 

- Activate the software environment: `mamba activate typing`.
- Fix the script provided in `scripts/06-iqtree.sh`. See @sec-iqtree if you need a hint of how to fix the code in the script.
- Run the script using `bash scripts/06-iqtree.sh`. Several messages will be printed on the screen while `iqtree` runs. 

Once the _IQ-TREE_ finishes running:

- Load the generated tree into _FigTree_.
- Import the annotations we provide in `resources/vibrio_genomes/public_genomes_metadata.tsv`.
- You can change the annotations shown on the tip labels from the menu panel on the left.

Answer the following questions:

- Do all your samples cluster together?
- Are they quite distinct (long branch lengths) compared to their closest public sequences?
- Do your samples cluster with the pathogenic O1 biotype?
- Which transmission wave are your samples most closely related to?
- Do these results agree with the result you obtained on _Pathogenwatch_?


:::{.callout-hint collapse=true}
For IQ-TREE: 

- The constant sites can be obtained by looking at the output of the `snp-sites` in `results/snp-sites/constant_sites.txt` (or in the `preprocessed` folder if you are still waiting for you _Panaroo_ analysis to finish).
- The input alignment should be the output from the `snp-sites` program in `results/snp-sites/core_genome_alignment_snps.aln` (or in the `preprocessed` folder if you are still waiting for you _Panaroo_ analysis to finish).

For _FigTree_: 

- To open a tree go to <kbd><kbd>File</kbd> > <kbd>Open...</kbd></kbd> and load the `.treefile` generated by _IQ-TREE_.
- To import sample metadata go to <kbd><kbd>File</kbd> > <kbd>Import annotations...</kbd></kbd>.
:::

:::{.callout-answer collapse=true}

The fixed script is: 

```bash
#!/bin/bash

# create output directory
mkdir -p results/iqtree/

# Run iqtree
iqtree -s results/snp-sites/core_gene_alignment_snps.aln -fconst 712485,634106,704469,704109 --prefix results/iqtree/ambroise -nt AUTO
```

- We specify as input the `core_gene_alignment_snps.aln` produced in the previous exercise by running _Panaroo_ followed by _SNP-sites_.
- We specify the number of constant sites, also generated from the previous exercise. We ran `cat results/snp-sites/constant_sites.txt` to obtain these numbers.
- We use as prefix for our output files "ambroise" (since we are using the "Ambroise 2023" data), so all the output file names will be named as such.
- We automatically detect the number of threads/CPUs for parallel computation.

After the analysis runs we get several output files in our directory: 

```bash
ls results/iqtree/
```

```
ambroise.bionj  ambroise.ckp.gz  ambroise.iqtree  
ambroise.log    ambroise.mldist  ambroise.treefile
```

The main file of interest is `ambroise.treefile`, which contains our tree in the standard [Newick format](https://en.wikipedia.org/wiki/Newick_format). 
We can load this tree into _FigTree_ from <kbd><kbd>File</kbd> > <kbd>Open...</kbd></kbd>. 
We also import the annotations provided for the public genomes from <kbd><kbd>File</kbd> > <kbd>Import Annotations...</kbd></kbd>. 

The resulting tree file is shown in the image below:

![](images/phylo_figtree_ambroise.png)

We have highlighted the the clades showing our samples (pint) and the main clade they fall into (purple). 
We can see that: 

- Do all your samples cluster together?
- Are they quite distinct (long branch lengths) compared to their closest public sequences?
- Do your samples cluster with the pathogenic O1 biotype?
- Which transmission wave are your samples most closely related to?
- Do these results agree with the result you obtained on _Pathogenwatch_?

- Our samples do cluster together, suggesting they are more similar to each other than to any other samples in the dataset. 
- They are quite distant from other public sequences in their clade. 
  This could be true divergence if, for example, the public sequences were collected a long time ago and/or from distant locations or outbreaks (we have no information about this). 
  Alternatively, this could be due to sequencing errors, in particular as we are working with an older chemistry of ONT data (R9.4.1 flowcells) with high sequencing error rates.
- Using _FigTree_, we changed the tip labels to show the "biotype" of the public samples, which confirmed that the closest sequences to ours belong to O1 biotype. 
- By changing the tip labels to "clade" we can see the closest sequences are from "W3 T10" transmission event. 

These results suggest that our samples are closely related to other "O1" strains, confirming their classification as also being that strain type. 
The results are also compatible with the analysis from _Pathogenwatch_. 
:::
:::


## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
