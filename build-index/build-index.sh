echo "Start building index"
cd /home/$USER/m5C-UBSseq/build-index

START_TIME=$(date +%s)

./dna-build-index.sh $1 &
./rna-build-index.sh $2 &

wait

END_TIME=$(date +%s)

RUNTIME=$((END_TIME - START_TIME))
hours=$((RUNTIME / 3600))
minutes=$(((RUNTIME % 3600) / 60))
seconds=$((RUNTIME % 60))
echo "Build index total runtime: ${hours}h ${minutes}m ${seconds}s"
