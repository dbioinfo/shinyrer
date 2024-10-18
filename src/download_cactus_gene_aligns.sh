#!/bin/bash

PREFIX="https://genome.senckenberg.de/download/TOGA/human_hg38_reference/MultipleCodonAlignments/"

while read fname 
do
	wget --no-check-certificate ${PREFIX}${fname} -P raw_data/cactus_aligns/gene_aligns/
	echo ${PREFIX}${fname}
done < raw_data/cactus_aligns/filelist.txt
