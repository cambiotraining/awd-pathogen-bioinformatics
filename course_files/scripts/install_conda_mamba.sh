#!/bin/bash

# Downloading conda in the current working dir
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh

## installing conda
bash Miniconda3-py310_23.3.1-0-Linux-x86_64.sh

## Activating conda manually
 eval "$(/home/bajuna/miniconda3/bin/conda shell.$(echo $O) hook)"

## Install mamba
conda install mamba -c conda-forge



