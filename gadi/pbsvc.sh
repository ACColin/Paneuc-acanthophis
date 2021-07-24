#!/bin/bash -l
#PBS -q normal
#PBS -l ncpus=192
#PBS -l walltime=48:00:00
#PBS -l mem=760G
#PBS -l storage=scratch/xe2+gdata/xe2
#PBS -o data/log/cluster/
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -P xe2

conda activate paneuc-acanthophis

set -xueo pipefail


regionparallel \
    -r "$REF" \
    -s 2000000 \
    "conda activate paneuc-acanthophis; snakemake --allowed-rules mpileup --notemp --use-conda --conda-frontend mamba\
     --ri -j 1 -p --nolock data/variants/raw_split/${KEY}/{region}.bcf"
