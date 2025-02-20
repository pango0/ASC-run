#!/bin/bash

START_TIME=$(date +%s)
time samtools view -@ $3 -e "rlen<100000" -h "$1"/gene.mRNA.genome.mapped.sorted.dedup.filtered.bam | \
hisat-3n-table \
    -p 4 \
    -m \
    --alignments - \
    --ref "$2" \
    --output-name /dev/stdout \
    --base-change C,T | \
cut -f 1,2,3,5,7 | pigz -p $3 -c > "$1"/gene_filtered_multi.tsv.gz
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-9 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene_filtered_multi.tsv.gz
