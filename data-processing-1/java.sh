#!/bin/bash

START_TIME=$(date +%s)
time java -verbose -server \
    -Xms32G -Xmx64G -Xss100M \
    -Djava.io.tmpdir="$1" \
    -jar $CONDA_PREFIX/share/umicollapse-1.1.0-0/umicollapse.jar bam \
    -t $(($2 - 2)) \
    -T $(($2 - 2)) \
    --data naive \
    --merge avgqual \
    --two-pass \
    -i "$1"/gene.mRNA.genome.mapped.sorted.bam \
    -o "$1"/gene.mRNA.genome.mapped.sorted.dedup.bam \
    > "$1"/gene.mRNA.genome.mapped.sorted.dedup.log
end_time=$(date +%s)
duration=$((end_time - START_TIME))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
echo "java duration: ${hours}h ${minutes}m ${seconds}s"
## produces gene.mRNA.genome.mapped.sorted.dedup.bam
