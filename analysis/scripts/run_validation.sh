#!/usr/bin/env bash

matlab -nodisplay -nodesktop -r "run synthesize_data.m; run validation.m; exit"

rm *.O
rm *.G
rm *.HL
rm *.wav
rm *.mat
