#!/usr/bin/env bash

# install R dependencies
cd analysis
RScript -e "list_of_packages <- c('lme4','multcomp','RColorBrewer','rptR'); new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,'Package'])]; cat(paste('Installing package',new_packages,'; ')); if(length(new_packages)>0) install.packages(new_packages, repos='http://cran.us.r-project.org')"

# download segmentation results
wget -O segmentation_results.zip http://span.usc.edu/owncloud/index.php/s/TR4oAXNrAfARsYT/download
unzip segmentation_results.zip
rm segmentation_results.zip

# download manual annotations
wget -O manual_annotations.zip http://span.usc.edu/owncloud/index.php/s/a3IK867EhTXfFBE/download
unzip manual_annotations.zip
rm manual_annotations.zip

# build model
cd scripts
./run_wrap_build_model.sh

# validate model
matlab -nodesktop -nodisplay -r "run validation.m; exit"
cd ../..

# make paper
cd paper
./make_paper.sh
cd ..

# make supplementary materials
cd supplementary_materials_01
./make_supppub1.sh

