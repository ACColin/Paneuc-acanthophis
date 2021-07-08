#!/bin/bash -l
#PBS -q normal
#PBS -l ncpus=2
#PBS -l walltime=48:00:00
#PBS -l mem=10G
#PBS -l storage=scratch/xe2+gdata/xe2
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -P xe2

conda activate  paneuc-acanthophis

set -ueo pipefail
TARGET=${TARGET:-all}
set -x

#snakemake \
#    -j 1 \
#    --use-conda \
#    --conda-frontend mamba \
#    --conda-create-envs-only 

python3 -m snakemake                \
    --profile ./gadi/               \
    --notemp                        \
    --local-cores ${PBS_NCPUS:-2}   \
    "$TARGET"                       \
    >data/submit.log 2>&1
