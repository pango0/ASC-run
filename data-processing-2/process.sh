#!/bin/bash

echo "Start processing datasets stage 2"
start_time=$(date +%s)

cp "$1"/gene_genome.arrow 1.arrow
cp "$2"/gene_genome.arrow 2.arrow
cp "$3"/gene_genome.arrow 3.arrow

set -e
echo "first cmd"
time python ../bin/group_pileup.py -i 1.arrow 2.arrow 3.arrow -o WT.arrow
echo "first cmd done"
echo "second cmd"
time python ../bin/select_sites.py -i ./WT.arrow -o ./WT.prefilter.tsv
echo "second cmd done"
set +e

# Run the last three commands in parallel
time python ../bin/filter_sites.py -i "$1"/gene_genome.arrow -m ./WT.prefilter.tsv -b "$1"/gene.bg.tsv -o "$1"/gene.filtered.tsv &

time python ../bin/filter_sites.py -i "$2"/gene_genome.arrow -m ./WT.prefilter.tsv -b "$2"/gene.bg.tsv -o "$2"/gene.filtered.tsv &

time python ../bin/filter_sites.py -i "$3"/gene_genome.arrow -m ./WT.prefilter.tsv -b "$3"/gene.bg.tsv -o "$3"/gene.filtered.tsv &

# Wait for all background jobs to complete
wait
echo "all jobs done"
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "Stage 2 total execution time: ${hours}h ${minutes}m ${seconds}s"