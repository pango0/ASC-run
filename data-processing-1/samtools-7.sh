#!/bin/bash

START_TIME=$(date +%s)
time samtools view -@ $2 \
    -e "[XM] * 20 <= (qlen-sclen) && [Zf] <= 3 && 3 * [Zf] <= [Zf] + [Yf]" \
    "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam \
    -O BAM \
    -o "$1"/gene.mRNA.genome.mapped.sorted.dedup.filtered.bam
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-7 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene.mRNA.genome.mapped.sorted.dedup.filtered.bam