#!/usr/bin/env bash

cd "./TADA/synth_data/"
matlab -nodisplay -nodesktop -r "run synthesize_data.m; exit"
