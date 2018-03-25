#!/usr/bin/env bash
pdflatex graphics/SuppPub1_ErrorFigure.tex
pdflatex graphics/SuppPub1_HistogramFigure.tex
pdflatex SuppPub1.tex
bibtex SuppPub1.aux
pdflatex SuppPub1.tex
pdflatex SuppPub1.tex
