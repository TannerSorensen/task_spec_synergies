#!/usr/bin/env bash

# clone repositories
cd analysis
#git clone https://github.com/usc-sail/span_contour_processing.git

# download segmentation results
#wget -O segmentation_results.zip http://span.usc.edu/owncloud/index.php/s/TR4oAXNrAfARsYT/download
#unzip segmentation_results.zip
#rm segmentation_results.zip

# build model
cd scripts
#matlab -nodisplay -nodesktop -r "run wrap_build_model.m; exit"
cd ../..

# make paper
cd paper
./make_paper.sh
cd ..

# make supplementary materials
cd supplementary_materials
./make_supppub1.sh
cd ..
