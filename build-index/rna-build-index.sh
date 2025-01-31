START_TIME=$(date +%s)
RNA_PATH=$1
hisat-3n-build -p 8 --base-change C,T "$1" "$1"
samtools faidx "$1"
END_TIME=$(date +%s)
RUNTIME=$((END_TIME - START_TIME))
hours=$((RUNTIME / 3600))
minutes=$(((RUNTIME % 3600) / 60))
seconds=$((RUNTIME % 60))
echo "RNA build index runtime: ${hours}h ${minutes}m ${seconds}s"
