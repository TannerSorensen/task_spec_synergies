#!/usr/bin/env bash

cd graphics
Rscript stats.R
for i in $(ls)
do
	pdfcrop $i $i
done
pdflatex SuppPub3_VelarHistogramFigure.tex
pdflatex SuppPub3_PharyngealHistogramFigure.tex
cd ..

pdflatex SuppPub3.tex

