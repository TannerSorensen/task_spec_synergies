#!/usr/bin/env bash
cd graphics
Rscript test_retest.R
cd ..
pdflatex SuppPub2.tex
