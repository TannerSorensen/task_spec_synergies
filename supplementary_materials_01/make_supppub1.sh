#!/usr/bin/env bash
cd graphics
Rscript err.R
Rscript histograms.R
pdflatex SuppPub2_ErrorFigure.tex
pdflatex SuppPub2_HistogramFigure.tex
cd ..

Rscript -e "library(knitr); knit('SuppPub2.Rnw')"
pdflatex SuppPub2.tex
bibtex SuppPub2.aux
pdflatex SuppPub2.tex
pdflatex SuppPub2.tex
