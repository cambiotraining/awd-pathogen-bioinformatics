#!/bin/bash



sudo rm -rf /usr/local/libexec/singularity /usr/local/var/singularity /usr/local/etc/singularity /usr/local/bin/singularity /usr/local/bin/run-singularity /usr/local/etc/bash_completion.d/singularity

sudo rm -rvf /usr/local/go/

export VERSION=1.20.4 OS=linux ARCH=amd64 && wget https://go.dev/dl/go$VERSION.$OS-$ARCH.tar.gz && sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && rm go$VERSION.$OS-$ARCH.tar.gz && export PATH=$PATH:/usr/local/go/bin

sudo apt-get install -y cryptsetup
sudo apt-get update && sudo apt-get install -y     build-essential     libssl-dev     uuid-dev     libgpgme11-dev     squashfs-tools

export VERSION=3.11.3 && wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz && tar -xzf singularity-ce-${VERSION}.tar.gz && cd singularity-ce-${VERSION}

sudo apt-get install libglib2.0-dev

./mconfig && sudo make -C builddir && sudo make -C builddir install