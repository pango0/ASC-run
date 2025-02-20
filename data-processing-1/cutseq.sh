#!/bin/bash

FQ_DIR=$1
THREADS=$2

BASENAME=$(basename "$FQ_DIR")

FQ_FILE="$FQ_DIR/$BASENAME.fq"


echo "FQ_FILE : $FQ_FILE"

START_TIME=$(date +%s)

time cutseq "$FQ_FILE" -t "$THREADS" -A INLINE -m 20 --trim-polyA --ensure-inline-barcode -o "$1"/gene-cut.fq -s "$1"/gene-tooshort.fq -u "$1"/gene-untrimmed.fq

end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "cutseq duration: ${hours}h ${minutes}m ${seconds}s"
# produce gene-cut.fq gene-tooshort.fq gene-untrimmed.fq
