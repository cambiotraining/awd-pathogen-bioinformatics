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
This section aims to answer: how do our Vibrio cholerae isolates relate to each other and to previously sequenced strains? 
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


## Phylogenies with Pathogenwatch

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
This shows that although our samples are related to W3 T3 reference samples, they have accumulated enough mutations that makes them cluster apart from the reference panel. 
Note that some of the lineage classification used by _Pathogenwatch_ may be slightly outdated, as new strains emerge that were not part of the 2017 study mentioned above. 

![Clicking on the "W3_T13" clade shows our samples in the context of the other reference genomes in this clade.](images/phylo_pathogenwatch03.png){#fig-phylo-pathogenwatch3}


### Using public genomes

We don't have to restrict our analysis to only the genomes provided by _Pathogenwatch_. 
We can create our own collections using publicly available genomes, for example [downloaded from NCBI](../02-assembly/01-preparing_data.md).

TODO - phylogeny with NCBI genomes


## Phylogenies with local software

In the previous section we used _Pathogenwatch_ to perform a phylogenetic analysis, using both our sequences and other _Vibrio_ genomes downloaded from NCBI. 
While Pathogenwatch is user-friendly, it relies on a web-based service that might not always be accessible. 
Therefore, we introduce an alternative using command line tools suitable for local execution on your computer.
The methodology we use here is similar to _Pathogenwatch_'s, but it employs distinct tools for generating the core genome and performing tree inference. 
Our toolkit consists of three software components:

- **[Panaroo]()** - used to identify a set of "core genes" (genes occurring in most samples) and generate a multiple sequence alignment from them.
- **[IQ-TREE]()** - used to infer a tree from the aligned core genes.
- **[Figtree]()** - used to visualise and/or annotate our tree.


### Core genome alignment: `panaroo`

The software [_Panaroo_](https://gtonkinhill.github.io/panaroo/) was developed to analyse bacterial pangenomes. 
It is able to identify orthologous sequences between a set of sequences, which it uses to produce a multiple sequence alignment of the core genome. 
The output alignment it produces can then be used to build our phylogenetic trees in the next step.

As input to _Panaroo_ we will use: 

- The gene annotations for our newly assembled genomes, which were produced during the [assembly pipeline](../02-assembly/03-genome_assembly.md) using _Bakta_. 
- Annotations from [public genomes downloaded from NCBI](https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=666&annotated_only=true&refseq_annotation=true&typical_only=true&assembly_level=3%3A3&release_year=2019%3A2023). 
  We chose complete genomes, annotated by NCBI RefSeq and submitted between 2019-2023 (a total of 63 genomes at the time these materials were written). 
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
TODO
```


### Tree inference: `iqtree`

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

We run _IQ-TREE_ on the output from _Panaroo_, i.e. using the core genome alignment to construct the phylogeny:

```bash
# create output directory
mkdir results/iqtree

# run iqtree2
iqtree2  -s results/panaroo/TODO.fasta --prefix results/iqtree/TODO
```

TODO output


## Exercises

:::{.callout-exercise}
#### Core genome alignment

TODO
:::

:::{.callout-exercise}
#### Tree inference

TODO
:::


## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
