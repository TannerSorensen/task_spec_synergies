#!/usr/bin/env bash

wget --output-document download.zip http://span.usc.edu/owncloud/index.php/s/JNjdOK5pOE9oyt5/download download.zip
unzip download.zip
rm download.zip

matlab -nodesktop -r "run main.m; exit"
