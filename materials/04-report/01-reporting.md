---
title: Reporting
---

::: {.callout-tip}
#### Learning Objectives

- TODO
:::


## Genomic surveillance report

After completing your analysis, it is advisable to write a report summarising your main findings. 
This report is intended to provide public health officials with well-informed insights for decisions concerning strain identification, outbreak source, transmission, control, mitigation measures, and treatment strategies for diseases like cholera or other infectious diseases you might be facing. 

In this chapter, we give an outline of the report's essential sections.
We took inspiration from a published report of a [cholera outbreak in Zambia in 2023](https://virological.org/t/vibrio-cholerae-genomics/939). 
We highly recommend that you also read that report to learn from it. 


:::{.callout-important}
#### Report template

We provide a report template as a [shared GDoc](https://docs.google.com/document/d/16RaclMEqDlJtFmB4mA8VVnP_dK4iKC-IcG6rDlBNADs/edit?usp=sharing), which you can download and adapt for your own analysis. 
However, we are not accredited public health officials, so please do not consider our template as an "official" document. 
:::


## Background

This segment offers a contextual backdrop for the report: 

- The current knowledge about the disease from sources such as the scientific literature and organisations such as the [World Health Organisation](https://www.who.int/health-topics/cholera#tab=tab_1), [Centers for Disease Control and Prevention](https://www.cdc.gov/cholera/index.html), amongst others. 
- Details about the outbreak seen in the region, answering questions such as:
  - When and where was the first case reported?
  - Does this outbreak follow other outbreaks in geographically close areas?
  - How many cases have been reported so far?
  - Have any treatments been used or any other preemptive measures put in place in the affected areas?
- How Whole Genome Sequencing (WGS) was integrated into the disease surveillance.

End this section by summarising the **main questions** that your report will address, such as: 

- Are the acute watery diarrhoea cases in the region caused by Vibrio cholerae?
- Are they pathogenic strains of Vibrio cholerae?
- Are they similar to previously sequenced strains in the region?
- Do these strains carry AMR genes and, if so, for which antimicrobial agents?


## Methods

This section should describe the methodologies used from sample collection to analysis.
This section should address the following:

- _When_ (date, time), _where_ (location, GPS coordinates) and _how_ were the samples collected from the patients?
- What kind of disease symptoms did the patients show?
- How were the samples processed in the lab - were they grown in plates for isolating colonies, or did you use a metagenomic approach?
- Were the strains characterised in the lab using assays such as serotyping and antibiotic susceptibility?
- How was the DNA extracted and sequencing libraries prepared? Detail the approach used (e.g. whole genome sequencing, amplicon-based, metagenomic) and details about kits and reagents used.
- What platform was used for sequencing (ONT, Illumina, PacBio)? Give details about the instrument models and any software versions in those platforms.
- For ONT data, how was basecalling performed, including the Guppy version used and the basecalling mode (fast, high accuracy, super high accuracy)?
- How was the bioinformatic analysis performed? This should include the names of all the software used and their versions.

For bioinformatic analysis, which is the focus of these materials, we give a detailed description of the analysis covered in previous chapters in our [template document](https://docs.google.com/document/d/16RaclMEqDlJtFmB4mA8VVnP_dK4iKC-IcG6rDlBNADs/edit?usp=sharing). 


## Results

This is where you provide the main results of your analysis.
This is the most crucial section of your report, as its content may inform subsequent decision-making by public health professionals. 
It covers essential results relevant to public health, including antimicrobial resistance (AMR), transmission source, and typing. 
The outputs from all the analysis tools we used in previous chapters contribute to this section. 
Inclusion of tables and plots from individual tool outputs is recommended.

For the bioinformatics component in particular, you can include several sub-sections within the results: 

- **Assembly quality** - the table output by our [assembly script](../02-assembly/04-assembly_quality.md), as well as the results from the [_Mash_ screening](../02-assembly/02-read_content.md) (for example, were any unexpected contaminants found?).
- **Multilocus sequence typing** - the results from [MLST analysis](../03-typing/02-mlst.md) and importantly whether your strains are pathogenic (_O1 El Tor_ or related). Also report whether the cholera toxin genes _ctxA_ and _ctxB_ are present in your assemblies. 
- **Phylogenetic relatedness** - a [phylogenetic tree](../03-typing/03-phylogeny.md) showing how your sequences relate to other sequences collected in the region or other public sequences.
- **Antimicrobial resistance** - the results from [AMR analysis](../03-typing/04-amr.md) including results from multiple tools and which antibiotic drugs your strains are likely to be resistant to.


## References

The report concludes with citations from relevant literature sources utilized in its preparation.


## Exercises

:::{.callout-exercise}
#### Writing a report

TODO

:::

## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
