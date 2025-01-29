#!/bin/bash
#SBATCH --job-name=samtools-4
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
time samtools index -@ 8 "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam.bai
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "samtools-4 duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene.mRNA.genome.mapped.sorted.dedup.bam.bai