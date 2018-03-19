#!/usr/bin/env bash

# clone repositories
cd analysis
#git clone https://github.com/usc-sail/span_contour_processing.git
#git clone https://github.com/usc-sail/span_articulatory_strategies.git

# download segmentation results
#wget -O segmentation_results.zip http://span.usc.edu/owncloud/index.php/s/TR4oAXNrAfARsYT/download
#unzip segmentation_results.zip
#rm segmentation_results.zip

# build model
cd scripts
#matlab -nodisplay -nodesktop -r "run wrap_build_model.m; exit"
#matlab -nodisplay -nodesktop -r "run wrap_articulatory_strategies.m; exit"

# run R scripts (see the .Rout files for text output, graphics subfolder for images)
Rscript test_retest.R
Rscript err.R
Rscript task_specificity.R

for pdf_file in $(ls ../graphics/*.pdf); do pdfcrop $pdf_file $pdf_file; done
