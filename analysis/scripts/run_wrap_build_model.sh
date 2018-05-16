#!/usr/bin/env bash

export TZ=America/Los_Angeles
source /usr/usc/matlab/R2018a/setup.sh
matlab -nodisplay -nodesktop -r "cluster=get_SLURM_cluster('--time=23:59:59'); run wrap_build_model.m; exit"
