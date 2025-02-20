#!/bin/bash

START_TIME=$(date +%s)
time samtools index -@ $2 "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam.bai
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-4 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene.mRNA.genome.mapped.sorted.dedup.bam.bai