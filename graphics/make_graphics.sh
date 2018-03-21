#!/usr/bin/env bash
wget -O data.zip http://span.usc.edu/owncloud/index.php/s/k4QR6LFumRgplZO/download
unzip data.zip
rm data.zip
mv sorensen_2018_graphics_data data

matlab -nodesktop -r "run graphs_segmentation.m; exit"

# declare a list of subfolders that contain images
declare -a subfolders=("mri" "segmentation" "constrictions" "histograms" "icc" "templates")

for subfolder in "${subfolders[@]}"
do
	cd $subfolder
	for pdf_file in *.pdf
	do
		pdfcrop "$pdf_file" "$pdf_file"
	done
	cd ..
done
