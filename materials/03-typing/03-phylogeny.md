---
title: Building phylogenetic trees
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::


## Pathogen Phylogenetics

The general aim of phylogenetic analysis is to infer the evolutionary relationships between different organisms. 
In the context of pathogenic organisms phylogenetics can be used, for example, to understand the origin of human-infecting strains. 
In this case, the focus is on inter-species differences, i.e. sequences from different species of bacteria/viruses are used, both from those infecting human hosts and those from other non-human species. 
For example, in the COVID19 pandemic, inter-species phylogeny was used to try and [infer the origin of the SARS-CoV-2 virus](https://doi.org/10.1007/s10311-020-01151-1) that evolved to infect humans. 

However, in the context of pathogen surveillance it is more common to focus on **intra-species phylogenies**. 
In this case, phylogenies are built from many sequences belonging to the same pathogenic species, and the aim is instead to understand how particular strains and lineages of the pathogen relate to each other and evolve.
By analysing the genetic differences between different strains, it is possible to track the spread of the pathogen and identify the source of outbreaks. 
This is the focus of this section, we aim to answer the question: how are our isolates of _Vibrio cholerae_ related to each other and to other strains that have previously been sequenced?

There are two main steps needed to build a phylogeny: 

- **Multiple sequence alignment** - because sequences may have different lengths due to insertions/deletions, we first need to make sure that homologous residues of each sequence are aligned with each other.
- **Tree inference** - once we have our alignment, we can use models of sequence evolution to infer the most likely relationship between those sequences, based on the substitutions that we observe between them.

The task of multiple sequence alignment is relatively simple when we are working with a single gene or with species that are very similar to each other (e.g. clonal bacterial species).
However, some species of bacteria can accumulate large differences due to events such as horizontal gene transfer (e.g. through conjugation or bacteriophages), gene duplication and gene loss. 
In these cases, the multiple sequence alignment should be made from the so-called **core genome**.
The core genome is the set of genes that is present in most members of a species, and can therefore be used to infer the evolutionary relationships between them. 
This is in comparison with the "accessory genome", which consists of the genes that are present only in some members of the species. 
The full set of core and accessory genomes observed in a species is often referred to as the **pangenome**. 

Because _Vibrio cholerae_ is known to be quite diverse, often aquiring new resistance genes through conjugation and phage-mediated horizontal transfer, phylogenetic inference is done by first producing a **core genome alignment**, which is then used for tree inference. 
We will explore how to build quick phylogenies from _Vibrio cholerae_ using Pathogenwatch, and then detail how you can make your own phylogenies using command line tools. 


## Phylogenies with Pathogenwatch

TODO


## Phylogenies with local software

In the previous section we used _Pathogenwatch_ to do a basic phylogenetic analysis, using both our sequences and other _Vibrio_ genomes downloaded from NCBI. 
Using _Pathogenwatch_ is relatively easy, but it is a web-based service, which may not always be available. 
Therefore, we introduce an alternative using command line tools that can be run locally on your computer. 
The approach we use here is not conceptually different to what _Pathogenwatch_ does, but it uses different tools to generate the core genome and tree inference. 
We will use three pieces of software: 

- **[Panaroo]()** - 
- **[IQ-TREE]()** - 
- **[Figtree]()** - for tree visualisation.

We will use the software [_Panaroo_](https://gtonkinhill.github.io/panaroo/), which was developed to analyse bacterial pangenomes. 
_Panaroo_ is able to identify orthologous sequences between a set of sequences, which it uses to produce a multiple sequence alignment of the core genome. 
We can then use the output alignment from this tool to build our phylogenetic trees in the next step.


## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
