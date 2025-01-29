#!/bin/bash
#SBATCH --job-name=cutseq
#SBATCH --partition=gp4d
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=180G
#SBATCH --time=96:00:00
#SBATCH --gpus-per-node=2
#SBATCH --account=ACD114010
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.err
# $1 is dir to dataset
START_TIME=$(date +%s)
time cutseq "$1"/gene.fq -t 8 -A INLINE -m 20 --trim-polyA --ensure-inline-barcode -o "$1"/gene-cut.fq -s "$1"/gene-tooshort.fq -u "$1"/gene-untrimmed.fq
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "cutseq duration: ${hours}h ${minutes}m ${seconds}s"
# produce gene-cut.fq gene-tooshort.fq gene-untrimmed.fq
