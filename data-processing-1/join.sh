#!/bin/bash
#SBATCH --job-name=join
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
START_TIME=$(date +%s)
time python /home/b11902044/m5C-UBSseq/bin/join_pileup.py \
    -i "$1"/gene_unfiltered_uniq.tsv.gz \
    "$1"/gene_unfiltered_multi.tsv.gz \
    "$1"/gene_filtered_uniq.tsv.gz \
    "$1"/gene_filtered_multi.tsv.gz \
    -o "$1"/gene_genome.arrow
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "join duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene_genome.arrow