#!/bin/bash

START_TIME=$(date +%s)

# FQ_DIR=$2

# BASENAME=$(basename "$FQ_DIR")

# FQ_FILE="$FQ_DIR/$BASENAME.gz"


# echo "FQ_FILE : $FQ_FILE"

time hisat-3n \
    --index "$2" \
    --summary-file "$1"/map2genome.output.summary \
    --new-summary \
    -q \
    -U "$1"/gene.mRNA.fastq \
    -p 48 \
    --base-change C,T \
    --mp 4,1 \
    --pen-noncansplice 20 \
    --directional-mapping | \
samtools view -@ $3 -e '!flag.unmap' \
    -O BAM \
    -U "$1"/gene.mRNA.genome.unmapped.bam \
    -o "$1"/gene.mRNA.genome.mapped.bam
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "hisat-3n-2 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene.mRNA.genome.unmapped.bam and gene.mRNA.genome.mapped.bam
