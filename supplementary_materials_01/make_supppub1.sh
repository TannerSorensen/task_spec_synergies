#!/usr/bin/env bash

cd graphics
for i in $(ls *.tex)
do
	pdflatex $i
done

rm *.aux
rm *.log
rm *.gz

mkdir SuppPub1
cp *.pdf SuppPub1/
zip -r ../SuppPub1.zip SuppPub1
rm -r SuppPub1

cd ..

