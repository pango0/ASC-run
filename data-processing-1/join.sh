#!/bin/bash

START_TIME=$(date +%s)
time python ../bin/join_pileup.py \
    -i "$1"/gene_unfiltered_uniq.tsv.gz \
    "$1"/gene_unfiltered_multi.tsv.gz \
    "$1"/gene_filtered_uniq.tsv.gz \
    "$1"/gene_filtered_multi.tsv.gz \
    -o "$1"/gene_genome.arrow
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "join duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene_genome.arrow
