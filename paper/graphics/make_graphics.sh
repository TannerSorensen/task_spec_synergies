#!/usr/bin/env bash

# remove the following directories if present
rm -rf data
rm -rf realtimeMRI
rm -rf templates

# download graphics data
wget -O data.zip http://span.usc.edu/owncloud/index.php/s/k4QR6LFumRgplZO/download
unzip data.zip
rm data.zip

# create directories
mv sorensen_2018_graphics_data data
mv -f data/realtimeMRI realtimeMRI
mv -f data/templates templates

# make MATLAB graphics
matlab -nodisplay -nodesktop -r "run graphs_segmentation.m; run graphs_factors.m; run graphs_biomarker.m; run graphs_validation; run graphs_gfa_var_expl.m; run graphs_templates.m; exit"

# make R graphics
Rscript histograms.R
Rscript err.R
Rscript test_retest.R

# declare a list of subfolders that contain images
declare -a subfolders=("cv_errors" "mri" "gfa" "segmentation" "constrictions" "histograms" "icc" "templates" "biomarker" "validation" "gfa_var_expl")

# crop all figures
for subfolder in "${subfolders[@]}"
do
        declare -a pdf_file_list=("$subfolder/*.pdf")
        for pdf_file in $pdf_file_list
	do
		pdfcrop "$pdf_file" "$pdf_file"
	done
done

# use LaTeX to combine panels into whole figures
pdflatex ConstrictionsFigure.tex
pdflatex ErrorFigure.tex
pdflatex FactorsFigure.tex
pdflatex HistogramsFigure.tex
pdflatex ICCFigure.tex
pdflatex RealtimeMRIFigure.tex
pdflatex SegTempFigure.tex
pdflatex BiomarkerFigure.tex
pdflatex ValidationFigure.tex
pdflatex VarExplFigure.tex

