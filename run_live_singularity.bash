#!/bin/bash

#Pull Docker Image from Singularity and Enter Singularity Shell
export DIR=/lscratch/${USER}/.singularity
mkdir $DIR -p
export SINGULARITY_LOCALCACHEDIR=$DIR
export SINGULARITY_CACHEDIR=$DIR
export SINGULARITY_TMPDIR=$DIR

singularity pull docker://singh96aman/lume-impact-live-demo:main
singularity shell lume-impact-live-demo_main.sif

conda init
source ~/.bashrc
conda activate lume-live-dev
bash /app/run_lume_live.bash
echo "ALL DONE"