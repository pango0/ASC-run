#!/bin/bash

START_TIME=$(date +%s)
time samtools view -@ $2 -F 3980 -c "$1"/gene.mRNA.genome.mapped.sorted.bam > "$1"/gene.mRNA.genome.mapped.sorted.bam.tsv
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-3 duration: ${hours}h ${minutes}m ${seconds}s"