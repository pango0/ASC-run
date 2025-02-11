#!/bin/bash
#SBATCH --job-name=samtools-5
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
time samtools view -e "rlen<100000" -h "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam | \
hisat-3n-table \
    -p 8 \
    -u \
    --alignments - \
    --ref "$2" \
    --output-name /dev/stdout \
    --base-change C,T | \
cut -f 1,2,3,5,7 | pigz -p 32 -c > "$1"/gene_unfiltered_uniq.tsv.gz
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-5 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene_unfiltered_uniq.tsv.gz
