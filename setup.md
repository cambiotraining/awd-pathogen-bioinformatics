---
title: "Data & Setup"
number-sections: false
---

<!-- 
Note for Training Developers:
We provide instructions for commonly-used software as commented sections below.
Uncomment the sections relevant for your materials, and add additional instructions where needed (e.g. specific packages used).
Note that we use tabsets to provide instructions for all three major operating systems.
-->

::: {.callout-warning level=2}
## Workshop Attendees

If you are attending one of our workshops, we will provide a training environment with all of the required software and data. 
There is no need for you to set anything up in advance. 
 
These instructions are for those who would like setup their own computer to run the analysis demonstrated on the materials.
:::


## Software

### Install Linux

::: {.panel-tabset group="os"}
#### Ubuntu

The recommendation for bioinformatic analysis is to have a dedicated computer running a Linux distribution. 
The kind of distribution you choose is not critical, but we recommend **Ubuntu** if you are unsure.

You can follow the [installation tutorial on the Ubuntu webpage](https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview). 

:::{.callout-warning}
Installing Ubuntu on the computer will remove any other operating system you had previously installed, and can lead to data loss. 
:::

#### Windows WSL

The **Windows Subsystem for Linux (WSL2)** runs a compiled version of Ubuntu natively on Windows. 

There are detailed instructions on how to install WSL on the [Microsoft documentation page](https://learn.microsoft.com/en-us/windows/wsl/install). 
But briefly:

- Click the Windows key and search for  _Windows PowerShell_, right-click on the app and choose **Run as administrator**. 
- Answer "Yes" when it asks if you want the App to make changes on your computer. 
- A terminal will open; run the command: `wsl --install`. 
  - This should start installing "ubuntu". 
  - It may ask for you to restart your computer. 
- After restart, click the Windows key and search for _Ubuntu_, click on the App and it should open a new terminal. 
- Follow the instructions to create a username and password (you can use the same username and password that you have on Windows, or a different one - it's your choice). 
- You should now have access to a Ubuntu Linux terminal. 
  This (mostly) behaves like a regular Ubuntu terminal, and you can install apps using the `sudo apt install` command as usual. 

After WSL is installed, it is useful to create shortcuts to your files on Windows. 
Your `C:\` drive is located in `/mnt/c/` (equally, other drives will be available based on their letter). 
For example, your desktop will be located in: `/mnt/c/Users/<WINDOWS USERNAME>/Desktop/`. 
It may be convenient to set shortcuts to commonly-used directories, which you can do using _symbolic links_, for example: 

- **Documents:** `ln -s /mnt/c/Users/<WINDOWS USERNAME>/Documents/ ~/Documents`
  - If you use OneDrive to save your documents, use: `ln -s /mnt/c/Users/<WINDOWS USERNAME>/OneDrive/Documents/ ~/Documents`
- **Desktop:** `ln -s /mnt/c/Users/<WINDOWS USERNAME>/Desktop/ ~/Desktop`
- **Downloads**: `ln -s /mnt/c/Users/<WINDOWS USERNAME>/Downloads/ ~/Downloads`

#### Virtual machine

Another way to run Linux within Windows (or macOS) is to install a Virtual Machine.
However, this is mostly suitable for practicing and **not suitable for real data analysis**.

Detailed instructions to install an Ubuntu VM using Oracle's Virtual Box is available from the [Ubuntu documentation page](https://ubuntu.com/tutorials/how-to-run-ubuntu-desktop-on-a-virtual-machine-using-virtualbox#1-overview).

**Note:** In the step configuring "Virtual Hard Disk" make sure to assign a large storage partition (at least 100GB).

:::


#### Update Ubuntu

After installing Ubuntu (through either of the methods above), open a terminal and run the following commands to update your system and install some essential packages: 

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y git
sudo apt install -y default-jre
```


### Conda/Mamba

We recommend using the _Conda_ package manager to install your software. 
In particular, the newest implementation called _Mamba_. 

To install _Mamba_, run the following commands from the terminal: 

```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh -b
rm Mambaforge-$(uname)-$(uname -m).sh
```

Restart your terminal (or open a new one) and confirm that your shell now starts with the word `(base)`.
Then run the following commands: 

```bash
conda config --add channels defaults; conda config --add channels bioconda; conda config --add channels conda-forge
conda config --set remote_read_timeout_secs 1000
```


### Software environments

Due to the complexities of the different tools we will use, there are several software dependency incompatibilities between them.
Therefore, rather than creating a single software environment with all the tools, we will create separate environments for different applications. 

#### Mash

```bash
mamba create -y -n mash mash
```

#### Assembly

```bash
mamba create -y -n assembly flye rasusa bakta medaka
```

<!-- 
```bash
# used for workshop:
mamba create -y -n assembly2 flye=2.9.2 rasusa=0.7.1 bakta=1.8.1 medaka=1.8.0
``` 
-->

#### CheckM2

```bash
mamba create -y -n checkm2 checkm2
```


#### Typing

```bash
mamba create -y -n typing mlst perl blast
```

#### Phylogeny

```bash
mamba create -y -n phylogeny panaroo iqtree figtree snp-sites
```

#### Nextflow

```bash
mamba create -y -n nextflow nextflow
```

Also run these commands to set _Nextflow_ correctly (copy/paste this entire code):

```bash
mkdir -p $HOME/.nextflow
echo "
conda {
  conda.enabled = true
  singularity.enabled = false
  docker.enabled = false
  useMamba = true
  createTimeout = '4 h'
  cacheDir = \"$HOME/.nextflow-conda-cache/\"
}
singularity {
  singularity.enabled = true
  conda.enabled = false
  docker.enabled = false
  pullTimeout = '4 h'
  cacheDir = \"$HOME/.nextflow-singularity-cache/\"
}
docker {
  docker.enabled = true
  singularity.enabled = false
  conda.enabled = false
}
" >> $HOME/.nextflow/config
```

### Bandage

Generally, this software does not require installation, it can be simply [downloaded from the website](https://rrwick.github.io/Bandage/), unzipped and run. 
However, we provide command-line instructions which will place the executable on the Desktop for easy access.

::: {.panel-tabset group="os"}
#### Ubuntu

From the command line: 

```bash
# install dependencies
sudo apt-get install -y qt5-default

# download the executable
wget -O bandage.zip "https://github.com/rrwick/Bandage/releases/download/v0.8.1/Bandage_Ubuntu_dynamic_v0_8_1.zip"
unzip bandage.zip -d bandage
mv bandage/Bandage ~/Desktop/
rm -r bandage.zip bandage
```

#### Windows WSL

From the WSL command line: 

```bash
wget -O bandage.zip "https://github.com/rrwick/Bandage/releases/download/v0.8.1/Bandage_Windows_v0_8_1.zip"
unzip bandage.zip -d bandage
mv bandage/Bandage ~/Desktop/
rm -r bandage.zip bandage
```

#### Virtual machine

You can follow the same instructions as for "Ubuntu".

:::


### Singularity

We recommend that you install _Singularity_ and use the `-profile singularity` option when running _Nextflow_ pipelines. 
On Ubuntu/WSL2, you can install _Singularity_ using the following commands: 

```bash
sudo apt install -y runc cryptsetup-bin uidmap
CODENAME=$(lsb_release -cs)
wget -O singularity.deb https://github.com/sylabs/singularity/releases/download/v3.11.4/singularity-ce_3.11.4-${CODENAME}_amd64.deb
sudo dpkg -i singularity.deb
rm singularity.deb
```

If you have a different Linux distribution, you can find more detailed instructions on the [_Singularity_ documentation page](https://docs.sylabs.io/guides/3.0/user-guide/installation.html#install-on-linux). 

If you have issues running _Nextflow_ pipelines with _Singularity_, then you can follow the instructions below for _Docker_ instead. 


### Docker

An alternative for software management when running _Nextflow_ pipelines is to use _Docker_. 

::: {.panel-tabset group="os"}
#### Ubuntu

For Ubuntu Linux, here are the installation instructions: 

```bash
sudo apt install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
```

After the last step, you will need to **restart your computer**. 
From now on, you can use `-profile docker` when you run _Nextflow_.

#### Windows WSL

When using WSL2 on Windows, running _Nextflow_ pipelines with `-profile singularity` sometimes doesn't work. 

As an alternative you can instead use _Docker_, which is another software containerisation solution. 
To set this up, you can follow the full instructions given on the Microsoft Documentation: [Get started with Docker remote containers on WSL 2](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers#install-docker-desktop).

We briefly summarise the instructions here (but check that page for details and images): 

- Download [_Docker_ for Windows](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe).
- Run the installer and install accepting default options. 
- Restart the computer.
- Open Docker and go to **Settings > General** to tick "Use the WSL 2 based engine".
- Go to **Settings > Resources > WSL Integration** to enable your Ubuntu WSL installation.

Once you have _Docker_ set and installed, you can use `-profile docker` when running your _Nextflow_ command.

#### Virtual machine

You can follow the same instructions as for "Ubuntu".
:::


### Visual Studio Code

::: {.panel-tabset group="os"}

#### Ubuntu

- Go to the [Visual Studio Code download page](https://code.visualstudio.com/Download) and download the installer for your Linux distribution. Install the package using your system's installer.

#### Windows WSL

- Go to the [Visual Studio Code download page](https://code.visualstudio.com/Download) and download the installer for your operating system. 
  Double-click the downloaded file to install the software, accepting all the default options. 
- After completing the installation, go to your Windows Menu, search for "Visual Studio Code" and launch the application. 
- Go to **File > Preferences > Settings**, then select **Text Editor > Files** on the drop-down menu on the left. Scroll down to the section named "_EOL_" and choose "_\\n_" (this will ensure that the files you edit on Windows are compatible with the Linux operating system).
- Click <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd>, which will open an "Extensions" panel on the left.
- Search for "WSL" and click "Install". 

From now on, you can open VS code directly from a WSL terminal by typing `code .`.

#### Virtual machine

You can follow the same instructions as for "Ubuntu".
:::


## Data

The data used in these materials is provided as a set of zip files. 
We provide instructions to download and uncompress the data via the command line, which is the recommended way to make sure you have the correct directory structure. 
However, we also provide the direct links to the zip files, in case you prefer to download them manually. 

First create a directory to store the files. 
Here, we create a directory for the workshop in the "Documents" folder (you can change this if you want to):

```bash
# create variable for working directory - change this if you want
workdir="$HOME/Documents/awd_bioinfo"
mkdir $workdir
```

### Resources

We provide files for databases and public genomes used in different parts of the analysis. 
These files are **required in addition to any other datasets**.
In summary, this contains four directories: 

- `mash_db` - database for the software _Mash_, covered in the [Read content](materials/02-assembly/02-read_content.md) chapter.
- `bakta_db` - database for the software _Bakta_, covered in the [Genome assembly](materials/02-assembly/03-genome_assembly.md) chapter.
- `CheckM2_database` - database for the _CheckM2_ program covered in the [Assembly quality](materials/02-assembly/04-assembly_quality.md) chapter.
- `vibrio_genomes` - public genomes downloaded from NCBI and used in the [Phylogenetics](materials/03-typing/03-phylogeny.md) chapter.

We recommend downloading this file once and then creating a _symbolic link_ (shortcut) to this folder from each of the analysis directories. 
This will reduce the storage space required for analysis. 

Download this file using the command line:

```bash
# make sure you are in the workshop folder
cd $workdir

# download and unzip
wget -O resources.zip "https://www.dropbox.com/sh/t8ivljixrg0z1qz/AAD9fGRSyQHrCizxrBU1VMB-a?dl=1"
unzip resources.zip -d resources
rm resources.zip  # remove original zip file to save space
```

If you want to download this file manually: 
[<i class="fa-solid fa-download"></i> download resources](https://www.dropbox.com/sh/t8ivljixrg0z1qz/AAD9fGRSyQHrCizxrBU1VMB-a?dl=0).


### Ambroise 2023

This dataset includes 5 samples sequenced on an ONT platform, and published in [Ambroise et al. 2023](https://doi.org/10.1101/2023.02.17.23286076). 
Here are the details about these data: 

- **Number of samples: **5
- **Origin: **samples from cholera patients from the Democratic Republic of the Congo.
- **Sample preparation: **stool samples were collected and used for plate culture in media appropriate to grow _Vibrio_ species; ONT library preparation and barcoding were done using standard kits.
- **Sequencing platform: **MinION
- **Basecalling: **Guppy version 6 in high accuracy ("hac") mode (this information is not actually specified in the manuscript, but we are making this assumption, just as an example).

To download the data, you can run the following commands: 

```bash
# make sure you are in the workshop folder
cd $workdir

# download and unzip
wget -O ambroise.zip "https://www.dropbox.com/sh/xytht4upehuo4c3/AABeYpICT2uAQzGBy4IzsKKwa?dl=1"
unzip ambroise.zip -d ambroise2023
rm ambroise.zip  # remove original zip file to save space

# create link to resources directory
ln -s $PWD/resources/ $PWD/ambroise2023/resources
```

If you want to download this file manually: 
[<i class="fa-solid fa-download"></i> download Ambroise 2023](https://www.dropbox.com/sh/xytht4upehuo4c3/AABeYpICT2uAQzGBy4IzsKKwa?dl=0).


### Scripts only

We also provide a folder containing only the scripts used in the exercises. 
This is useful if you want to **use your own data**. 

Here are the commands to download these data: 

```bash
# make sure you are in the workshop folder
cd $workdir

# download and unzip
wget -O minimal.zip "https://www.dropbox.com/sh/f421dkyos4us4ty/AABmomHwzL1miVvStaDQA4gma?dl=1"
unzip minimal.zip -d minimal
rm minimal.zip  # remove original zip file to save space

# create link to resources directory
ln -s $PWD/resources/ $PWD/minimal/resources
```

If you want to download this file manually: 
[<i class="fa-solid fa-download"></i> download scripts only](https://www.dropbox.com/sh/f421dkyos4us4ty/AABmomHwzL1miVvStaDQA4gma?dl=0).
