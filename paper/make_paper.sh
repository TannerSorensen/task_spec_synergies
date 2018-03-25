#!/usr/bin/env bash

./graphics/make_graphics.sh
Rscript -e "library(knitr); knit('synergy_paper.Rns')"
pdflatex synergy_paper.tex
bibtex synergy_paper.aux
pdflatex synergy_paper.tex
pdflatex synergy_paper.tex
