#!/usr/bin/env bash

usc_hpc_flag=0
if [ $usc_hpc_flag -eq 1 ]
then
	export TZ=America/Los_Angeles
	source /usr/usc/matlab/R2018a/setup.sh
	matlab -nodisplay -nodesktop -r "cluster=get_SLURM_cluster('--time=23:59:59'); run wrap_build_model.m; exit"
else
	matlab -nodisplay -nodesktop -r "run wrap_build_model.m; exit"
fi

