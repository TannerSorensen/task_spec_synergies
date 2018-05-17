#!/usr/bin/env bash
cd graphics
Rscript err.R
Rscript histograms.R
pdflatex SuppPub4_ErrorFigure.tex
pdflatex SuppPub4_HistogramFigure.tex
cd ..

Rscript -e "library(knitr); knit('SuppPub4.Rnw')"
