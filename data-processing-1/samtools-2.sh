#!/bin/bash

START_TIME=$(date +%s)
time samtools sort -@ $2 --write-index -O BAM -o "$1"/gene.mRNA.genome.mapped.sorted.bam "$1"/gene.mRNA.genome.mapped.bam
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-2 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene.mRNA.genome.mapped.sorted.bam