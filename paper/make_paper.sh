#!/usr/bin/env bash

cd graphics
./make_graphics.sh
cd ..

Rscript -e "library(knitr); knit('synergy_paper.Rnw')"
pdflatex synergy_paper.tex
bibtex synergy_paper.aux
pdflatex synergy_paper.tex
pdflatex synergy_paper.tex
