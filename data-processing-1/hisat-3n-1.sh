#!/bin/bash

START_TIME=$(date +%s)
echo "1: $1"
echo "2: $2"
THREADS=$3


time hisat-3n \
    --index "$2" \
    --summary-file "$1"/map2ncrna.output.summary \
    --new-summary \
    -q \
    -U "$1"/gene-cut.fq \
    -p 8 \
    --base-change C,T \
    --mp 8,2 \
    --no-spliced-alignment \
    --directional-mapping | \
samtools view -@ $THREADS -e '!flag.unmap' \
    -O BAM \
    -U "$1"/gene.ncrna.unmapped.bam \
    -o "$1"/gene.ncrna.mapped.bam
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "hisat-3n-1 duration: ${hours}h ${minutes}m ${seconds}s"
# produces gene.ncrna.unmapped.bam and gene.ncrna.mapped.bam
