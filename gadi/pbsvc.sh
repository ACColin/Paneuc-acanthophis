#!/bin/bash -l
#PBS -q normal
#PBS -l ncpus=1440
#PBS -l walltime=10:00:00
#PBS -l mem=5700G
#PBS -l storage=scratch/xe2+gdata/xe2
#PBS -o data/log/cluster/
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -P xe2

conda activate paneuc-acanthophis

set -xueo pipefail

regionparallel \
    -r rawdata/references/Emelliodora_GCA_004368105.2/GCA_004368105.2_ASM436810v2_genomic.fa \
    -s 2000000 \
    'conda activate paneuc-acanthophis; snakemake --allowed-rules mpileup --notemp --use-conda --conda-frontend mamba --ri -j 1 -p --nolock data/variants/raw_split/mpileup~bwa~Emelliodora_GCA_004368105.2~HBDecra/{region}.bcf'
