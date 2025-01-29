#!/bin/bash
#SBATCH --job-name=hisat-3n-2
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
time hisat-3n \
    --index /work/b11902044/reference/genome/Homo_sapiens.GRCh38.genome/Homo_sapiens.GRCh38.genome.fa \
    --summary-file "$1"/map2genome.output.summary \
    --new-summary \
    -q \
    -U "$1"/gene.mRNA.fastq \
    -p 8 \
    --base-change C,T \
    --mp 4,1 \
    --pen-noncansplice 20 \
    --directional-mapping | \
samtools view -@ 8 -e '!flag.unmap' \
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