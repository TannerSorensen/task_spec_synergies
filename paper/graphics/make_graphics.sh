#!/usr/bin/env bash
wget -O data.zip http://span.usc.edu/owncloud/index.php/s/k4QR6LFumRgplZO/download
unzip data.zip
rm data.zip
mv sorensen_2018_graphics_data data

# make MATLAB graphics
matlab -nodesktop -r "run graphs_segmentation.m; exit"

# make R graphics
Rscript histograms.R
Rscript err.R
Rscript test_retest.R

# declare a list of subfolders that contain images
declare -a subfolders=("cv_errors" "mri" "segmentation" "constrictions" "histograms" "icc" "templates")

for subfolder in "${subfolders[@]}"
do
	cd $subfolder
	for pdf_file in *.pdf
	do
		pdfcrop "$pdf_file" "$pdf_file"
	done
	cd ..
done

# use LaTeX to combine panels into whole figures
pdflatex ConstrictionsFigure.tex
pdflatex ErrorFigure.tex
pdflatex FactorsFigure.tex
pdflatex HistogramsFigure.tex
pdflatex ICCFigure.tex
pdflatex RealtimeMRIFigure.tex
pdflatex SegTempFigure.tex
