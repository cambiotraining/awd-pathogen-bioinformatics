---
title: Introduction to NGS
---

::: {.callout-tip}
#### Learning Objectives
- Describe differences between sequencing data produced by Illumina and Nanopore platforms.
- Recognise the structure of common file formats in bioinformatics, in particular FAST5, FASTA, FASTQ and  GFF3 files.

- TODO
:::

## Next Generation Sequencing

The sequencing of genomes has become more routine due to the rapid drop in DNA sequencing costs seen since the development of Next Generation Sequencing (NGS) technologies in 2007. One main feature of these technologies is that they are high-throughput, allowing one to more fully characterise the genetic material in a sample of interest.

There are three main technologies in use nowadays, often referred to as 2nd and 3rd generation sequencing:

- Illumina’s sequencing by synthesis (2nd generation)
- Oxford Nanopore, shortened ONT (3rd generation)
- Pacific Biosciences, shortened PacBio (3rd generation)

### Illumina Sequencing

Illumina’s technology has become a widely popular method, with many applications to study transcriptomes (RNA-seq), epigenomes (ATAC-seq, BS-seq), DNA-protein interactions (ChIP-seq), chromatin conformation (Hi-C/3C-Seq), population and quantitative genetics (variant detection, GWAS), de-novo genome assembly, amongst many others.

An overview of the sequencing procedure is shown in the animation video below. Generally, samples are processed to generate so-called sequencing libraries, where the genetic material (DNA or RNA) is processed to generate fragments of DNA with attached oligo adapters necessary for the sequencing procedure (if the starting material is RNA, it can be converted to DNA by a step of reverse transcription). Each of these DNA molecule is then sequenced from both ends, generating pairs of sequences from each molecule, i.e. paired-end sequencing (single-end sequencing, where the molecule is only sequenced from one end is also possible, although much less common nowadays).

This technology is a type of short-read sequencing, because we only obtain short sequences from the original DNA molecules. Typical protocols will generate 2x50bp to 2x250bp sequences (the 2x denotes that we sequence from each end of the molecule).

The main advantage of Illumina sequencing is that it produces very high-quality sequence reads (current protocols generate reads with an error rate of less than <1%) at a low cost. However, the fact that we only get relatively short sequences means that there are limitations when it comes to resolving particular problems such as long sequence repeats (e.g. around centromeres or transposon-rich areas of the genome), distinguishing gene isoforms (in RNA-seq), or resolving haplotypes (combinations of variants in each copy of an individual’s diploid genome).

### Nanopore Sequencing

Nanopore sequencing is a type of long-read sequencing technology. The main advantage of this technology is that it can sequence very long DNA molecules (up to megabase-sized), thus overcoming the main shortcoming of short-read sequencing mentioned above. Another big advantage of this technology is its portability, with some of its devices designed to work via USB plugged to a standard laptop. This makes it an ideal technology to use in situations where it is not possible to equip a dedicated sequencing facility/laboratory (for example, when doing field work).

![Overview of Nanopore sequencing showing the highly-portable MinION device. The device contains thousands of nanopores embeded in a membrane where current is applied. As individual DNA molecules pass through these nanopores they cause changes in this current, which is detected by sensors and read by a dedicated computer program. Each DNA base causes different changes in the current, allowing the software to convert this signal into base calls.](https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41587-021-01108-x/MediaObjects/41587_2021_1108_Fig1_HTML.png?as=webp)

One of the bigger challenges in effectively using this technology is to produce sequencing libraries that contain high molecular weight, intact, DNA. Another disadvantage is that, compared to Illumina sequencing, the error rates at higher, at around 5%, though recently there is a significant improvement in the technology where the error rate has be reduced to approximately 1% as detailed [here](https://mycota.com/an-open-letter-regarding-the-efficacy-and-error-rates-of-nanopore-sequencing-for-mass-barcoding-macrofungi/)

:::note
**Which technology to choose??**

Both of these platforms have been widely popular for bacterial sequencing sequencing. 
They can both generate data with high-enough quality for the assembly and analysis for most of the pathogen genomic surveillance.  
Mostly, which one you use will depend on what sequencing facilities you have access to. 

While Illumina provides the cheapest option per sample of the two, it has a higher setup cost, requiring access to the expensive sequencing machines. 
On the other hand, Nanopore is a very flexible platform, especially its portable MinION devices. 
They require less up-front cost allowing getting started with sequencing very quickly in a standard molecular biology lab. This also makes the ONT technolgies quite affordable for many low-resource settings countries.

:::

## Bioinformatics file formats

 Bioinformatics uses many standard file formats to store different types of data. There are different commonly used file formats. In this material we will discuss the few formats, but there are many other formats. Check out our page on [Extras → File Formats](https://cambiotraining.github.io/sars-cov-2-genomics/106-file_formats.html) to learn more about them.

### FAST5

FAST5 is a proprietary format developed by Oxford Nanopore Technologies, though based on the 'hierarchical data format' HDF5 format which enables storage of large and comples data. It is a standard output from Nanopre sequencers such as MinION. All FAST5 files have the `Raw/` field, which contains the original measured raw current signal. Additional `Analyses/` fields can be added by tools such as basecallers which convert signal to standard FASTQ data (e.g. Guppy basecaller). In contrast to fasta and fastq files a FAST5 file is binary and can not be opened with a normal text editor. 

For further detailed of this format you encouraged to read [this](https://static-content.springer.com/esm/art%3A10.1038%2Fs41587-021-01147-4/MediaObjects/41587_2021_1147_MOESM1_ESM.pdf) suplementary material from Nature.

### FASTQ

FASTQ files are used to store nucleotide sequences along with a quality score for each nucleotide of the sequence. 
These files are the typical format obtained from NGS sequencing platforms such as Illumina and Nanopore (after basecalling). 

The file format is as follows:

```
@SEQ_ID                   <-- SEQUENCE NAME
AGCGTGTACTGTGCATGTCGATG   <-- SEQUENCE
+                         <-- SEPARATOR
%%).1***-+*''))**55CCFF   <-- QUALITY SCORES
```

In FASTQ files each sequence is always represented across 4 lines. 
The quality scores are encoded in a compact form, using a single character. 
They represent a score that can vary between 0 and 40 (see [Illumina's Quality Score Encoding](https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/QualityScoreEncoding_swBS.htm)). 
The reason single characters are used to encode the quality scores is that it saves space when storing these large files. 
Software that work on FASTQ files automatically convert these characters into their score, so we don't have to worry about doing this conversion ourselves.

The quality value in common use is called a _Phred score_ and it represents the probability that the respective base is an error. 
For example, a base with quality 20 has a probability $10^{-2} = 0.01 = 1\%$ of being an error. 
A base with quality 30 has $10^{-3} = 0.001 = 0.1\%$ chance of being an error. 
Typically, a Phred score threshold of >20 or >30 is used when applying quality filters to sequencing reads. 

Because FASTQ files tend to be quite large, they are often _compressed_ to save space. 
The most common compression format is called _gzip_ and uses the extension `.gz`.
To look at a _gzip_ file, we can use the command `zcat`, which decompresses the file and prints the output as text. 

For example, we can use the following command to count the number of lines in a compressed FASTQ file:

```console
$ zcat sequences.fq.gz | wc -l
```

If we want to know how many sequences there are in the file, we can divide the result by 4 (since each sequence is always represented across four lines).


### FASTA

Another very common file that we should consider is the FASTA format.
FASTA files are used to store nucleotide or amino acid sequences.

The general structure of a FASTA file is illustrated below:

```
>sample01                 <-- NAME OF THE SEQUENCE
AGCGTGTACTGTGCATGTCGATG   <-- SEQUENCE ITSELF
```

Each sequence is represented by a name, which always starts with the character `>`, followed by the actual sequence.

A FASTA file can contain several sequences, for example:

```
>sample01
AGCGTGTACTGTGCATGTCGATG
>sample02
AGCGTGTACTGTGCATGTCGATG
```

Each sequence can sometimes span multiple lines, and separate sequences can always be identified by the `>` character. For example, this contains the same sequences as above:

```
>sample01      <-- FIRST SEQUENCE STARTS HERE
AGCGTGTACTGT
GCATGTCGATG
>sample02      <-- SECOND SEQUENCE STARTS HERE
AGCGTGTACTGT
GCATGTCGATG
```

To count how many sequences there are in a FASTA file, we can use the following command:

```console
grep ">" sequences.fa | wc -l
```

In two steps:

* find the lines containing the character ">", and then
* count the number of lines of the result.

We will see FASTA files several times throughout this course, so it's important to be familiar with them. 


### GFF3

A GFF (general feature format; file extension .gff2 or .gff3) describes the various sequence elements that make up a gene and is a standard way of annotating genomes. It defines the features present within a gene in the body of the GFF file, including transcripts, regulatory regions, untranslated regions, exons, introns, and coding sequences. It uses a header region with a “##” string to include metadata.

TODO

## Summary

::: {.callout-tip}
#### Key Points

- TODO
:::
