---
title: "Bioinformatics for AWD-related Pathogens"
author: "Bajuna Salehe, Hugo Tavares, Angelika Kritz, Sam Sims, Antoine Fayad, Luke Meredith, Matt Castle, Babak Afrough"
date: today
number-sections: false
---

## Overview 

According to the [World Health Organisation (WHO)](https://www.who.int/news-room/fact-sheets/detail/cholera), outbreaks of acute watery diarrhea (AWD) related diseases are likely to occur, unless surveillance systems are in place to rapidly detect their associated pathogen(s) and respond accordingly with public health measures. 
These surveillance systems can also help to determine the source of transmission, ensure implementation of control measures in the affected area and determine the microbial etiology associated with the outbreak.

These materials cover how genome analysis can be used for pathogen surveillance, detailing the bioinformatic analysis workflow to go from raw sequencing data, to the assembly of bacterial genomes, identification of pathogenic strains and screening for antibiotic resistance genes. 
We use cholera as a case study, however the tools and concepts covered also apply to other bacterial pathogens. 

::: {.callout-tip}
### Learning Objectives

- Describe how genome sequencing data can be used in the surveillance of bacterial pathogens.
- Understand how sequencing data is generated and the most common file formats and conventions used in the bioinformatics field. 
- Use the command line to run software tools for the bioinformatic analysis of sequencing data.
- Perform bacterial genome assembly from Oxford Nanopore Techologies (ONT) sequencing data.
- Characterise the assembled genomes by identifying strains and lineages, phylogeny and presence of antibiotic resistance genes. 
- Produce a report summarising the main findings of the analysis, to use for public health decisions.
:::

### Target Audience

This course is primarily aimed at public health officials including doctors, lab workers and clinicians who work with waterborne or foodborne diseases (in particular cholera) and would like to get started in using genomic and bioinformatics approaches for the surveillance of their causative bacterial pathogens.
We assume little or no prior experience in bioinformatics. 

### Prerequisites

- Basic understanding of microbiology.
- A working knowledge of the UNIX command line will be advantageous, but not required as we will give a brief introduction as part of the course.

<!-- Training Developer note: comment the following section out if you did not assign levels to your exercises 
### Exercises

Exercises in these materials are labelled according to their level of difficulty:

| Level | Description |
| ----: | :---------- |
| {{< fa solid star >}} {{< fa regular star >}} {{< fa regular star >}} | Exercises in level 1 are simpler and designed to get you familiar with the concepts and syntax covered in the course. |
| {{< fa solid star >}} {{< fa solid star >}} {{< fa regular star >}} | Exercises in level 2 combine different concepts together and apply it to a given task. |
| {{< fa solid star >}} {{< fa solid star >}} {{< fa solid star >}} | Exercises in level 3 require going beyond the concepts and syntax introduced to solve new problems. |
-->

## Authors
<!-- 
The listing below shows an example of how you can give more details about yourself.
These examples include icons with links to GitHub and Orcid. 
-->

About the authors:

- **Bajuna Salehe**
  <a href="https://github.com/bsalehe" target="_blank"><i class="fa-brands fa-github" style="color:#4078c0"></i></a>  
  _Affiliation_: Bioinformatics Training Facility, University of Cambridge  
  _Roles_: writing - original content; conceptualisation; coding; data curation
- **Hugo Tavares**
  <a href="https://orcid.org/0000-0001-9373-2726" target="_blank"><i class="fa-brands fa-orcid" style="color:#a6ce39"></i></a> 
  <a href="https://github.com/tavareshugo" target="_blank"><i class="fa-brands fa-github" style="color:#4078c0"></i></a>  
  _Affiliation_: Bioinformatics Training Facility, University of Cambridge  
  _Roles_: writing - original content; conceptualisation; coding; data curation
- **Angelika Kritz**  
  _Affiliation_: New Variant Assessment Platform, UK Health Security Agency  
  _Roles_: writing - review; conceptualisation; code review
- **Sam Sims**  
  _Affiliation_: New Variant Assessment Platform, UK Health Security Agency  
  _Roles_: coding; code review
- **Antoine Abou Fayad**  
  _Affiliation_: American University of Beirut  
  _Roles_: resources
- **Luke William Meredith**  
  _Affiliation_: World Health Organisation (EMRO)  
  _Roles_: project administration; funding acquisition; resources
- **Matt Castle**  
  _Affiliation_: Bioinformatics Training Facility, University of Cambridge  
  _Roles_: project administration; funding acquisition; resources
- **Babak Afrough**  
  _Affiliation_: New Variant Assessment Platform, UK Health Security Agency  
  _Roles_: project administration; funding acquisition; resources


## Citation

<!-- We can do this at the end -->

Please cite these materials if:

- You adapted or used any of them in your own teaching.
- These materials were useful for your research work. For example, you can cite us in the methods section of your paper: "We carried our analyses based on the recommendations in _Salehe & Tavares et al. (2023)_.".

You can cite these materials as:

> Salehe B, Tavares H, Kritz A, Sims S, Fayad AA, Meredith LW, Castle M & Afrough B (2023) “cambiotraining/awd-pathogen-bioinformatics: Bioinformatics for AWD-related Pathogens”, https://cambiotraining.github.io/awd-pathogen-bioinformatics

<!-- Or in BibTeX format:

```
@Misc{,
  author = {},
  title = {},
  month = {},
  year = {},
  url = {},
  doi = {}
}
``` -->


## Acknowledgements

<!-- if there are no acknowledgements we can delete this section -->

We thank Andries van Tonder (Department of Veterinary Medicine, University of Cambridge), Katy Brown (Department of Pathology, University of Cambridge) and Sebastian Bruchmann (Department of Medicine, University of Cambridge) for critical discussions and advice on these materials, as well as their work as lead trainers in live workshops.