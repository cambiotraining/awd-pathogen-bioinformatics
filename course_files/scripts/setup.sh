#!/bin/bash

## Create a workshop directory from $HOME/Documents
cd $HOME/Documents
mkdir -p cholera_workshop/results cholera_workshop/reports cholera_workshop/resources cholera_workshop/reference_genomes
cd cholera_workshop

## copy workshop data
wget -O data.zip "https://www.dropbox.com/s/p6lpbak7b6dvlx6/fastq_pass.zip?dl=1"
unzip data.zip
## Concatenate clean barcodes into a single directory
mkdir -p data/fastq_pass/clean
bash scripts/concat_fastq.sh

# Download and install conda and mamba.
bash scripts/install_conda_mamba.sh

# Install java
bash scripts/java_installation.sh

# Install nextflow
bash scripts/nextflow_installation.sh

# Install singularity
bash scripts/install_singularity.sh

# Run epi2me/wf-bacterial-genome after nextflow installation as follows to test if nextflow works
# nextflow run epi2me-labs/wf-bacterial-genomes --help > test_pipeline/nextflow_out.txt

# Run nf-core/funcscan with nextflow
# nextflow run nf-core/funcscan -profile test,singularity > test_pipeline/funcscan_out.txt

# # Setting up conda environment for the workshop
conda create -n cholera_workshop python=3.9
conda activate cholera_workshop

# Install mash using conda
mamba install -c bioconda mash

# Install panaroo through mamba
mamba install -c conda-forge -c bioconda -c defaults 'panaroo>=1.3'

# Install quast using conda
mamba install -c bioconda quast
    # The following packages needs to be downloaded separately after succesful installation:-
    #* GRIDSS (needed for structural variants detection)                                                                                                                                                                
    #* SILVA 16S rRNA database (needed for reference genome detection in metagenomic datasets)                                                                                                                          
    #* BUSCO tools and databases (needed for searching BUSCO genes) -- works in Linux only!                                                                                                                             
                                                                                                                                                                                                                    
    #To be able to use those, please run                                                                                                                                                                                
    #quast-download-gridss                                                                                                                                                                                          
    #quast-download-silva                                                                                                                                                                                           
quast-download-busco ## Download this one to be able to use the --conserved-genes-finding option for finding conserved genes in the assemblies                                                                                                                                                                                

# Install MultiQC using conda
mamba install multiqc

# Install checkM
#conda install -c bioconda numpy matplotlib pysam
#conda install -c bioconda hmmer prodigal pplacer
#pip3 install checkm-genome

## Create directory for checkM database
#mkdir -p data/checkM_databases
#cd data/checkM_databases
#wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz

mamba install -c bioconda checkm-genome

# Install MaxBin
mamba install -c bioconda maxbin2=2.2.7 ## to generate bins for checkM
# Alternatively
# wget https://sourceforge.net/projects/maxbin/files/MaxBin-2.2.7.tar.gz/download
# rm download
# cd MaxBin-2.2.7/
# conda install -c bioconda bowtie2
# ./autobuild_auxiliary
# echo "export PATH=$PATH:/home/bajuna/software/MaxBin-2.2.7" >> ~/.bashrc
# source ~/.bashrc
# conda activate cholera_workshop

# Install busco
# Latest version
mamba install -c conda-forge -c bioconda busco=5.4.7
# Alternatively
#git clone https://gitlab.com/ezlab/busco.git
#cd busco/
#sudo python3 setup.py install

mamba install -c conda-forge -c bioconda -c defaults mlst


