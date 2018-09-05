#!/usr/bin/env bash
cd graphics
Rscript err.R
Rscript histograms.R
pdflatex SuppPub5_ErrorFigure.tex
pdflatex SuppPub5_HistogramFigure.tex
cd ..

Rscript -e "library(knitr); knit('SuppPub5.Rnw')"
pdflatex SuppPub5.tex
bibtex SuppPub5.aux
pdflatex SuppPub5.tex
pdflatex SuppPub5.tex