echo "Start building index"
# cd build-index

START_TIME=$(date +%s)

./dna-build-index.sh $1 > dna-build.log 2> dna-build.err &
./rna-build-index.sh $2 > rna-build.log 2> rna-build.err &

wait

END_TIME=$(date +%s)

RUNTIME=$((END_TIME - START_TIME))
hours=$((RUNTIME / 3600))
minutes=$(((RUNTIME % 3600) / 60))
seconds=$((RUNTIME % 60))
echo "Build index total runtime: ${hours}h ${minutes}m ${seconds}s"
