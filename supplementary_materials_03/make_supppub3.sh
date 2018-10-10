#!/usr/bin/env bash
cd graphics
Rscript err.R
Rscript histograms.R
pdflatex SuppPub3_ErrorFigure.tex
pdflatex SuppPub3_HistogramFigure.tex
cd ..

Rscript -e "library(knitr); knit('SuppPub3.Rnw')"
pdflatex SuppPub3.tex
bibtex SuppPub3.aux
pdflatex SuppPub3.tex
pdflatex SuppPub3.tex
