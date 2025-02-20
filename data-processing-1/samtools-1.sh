#!/bin/bash

START_TIME=$(date +%s)
time samtools fastq -@ $2 -O "$1"/gene.ncrna.unmapped.bam > "$1"/gene.mRNA.fastq
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-1 duration: ${hours}h ${minutes}m ${seconds}s"
# produces gene.mRNA.fastq