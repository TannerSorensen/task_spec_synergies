#!/usr/bin/env bash
cd graphics
Rscript err.R
Rscript histograms.R
pdflatex SuppPub1_ErrorFigure.tex
pdflatex SuppPub1_HistogramFigure.tex
cd ..

Rscript -e "library(knitr); knit('SuppPub1.Rnw')"
pdflatex SuppPub1.tex
bibtex SuppPub1.aux
pdflatex SuppPub1.tex
pdflatex SuppPub1.tex
