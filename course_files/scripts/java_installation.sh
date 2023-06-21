#!/bin/bash

sudo apt update

## Both methods will install the same java 11

# sudo java -version

# method1: general
# sudo apt remove --purge default-jre

# sudo apt install --purge default-jdk


# method2: For nextflow

sdk install java 17.0.6-amzn

sdk install java 17.0.6-tem

sudo apt update
