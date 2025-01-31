START_TIME=$(date +%s)
GENOME_PATH=$1
hisat-3n-build -p 8 --base-change C,T "$1" "$1"
samtools faidx "$1"
awk 'BEGIN{{OFS="\\t"}}{{print $1,$1,0,$2,"+"}}' "$1".fai > "$1".saf
END_TIME=$(date +%s)
RUNTIME=$((END_TIME - START_TIME))
hours=$((RUNTIME / 3600))
minutes=$(((RUNTIME % 3600) / 60))
seconds=$((RUNTIME % 60))
echo "DNA build index runtime: ${hours}h ${minutes}m ${seconds}s"