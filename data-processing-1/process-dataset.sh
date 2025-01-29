#!/bin/bash
#SBATCH --job-name=process-dataset
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

# Load environment
module load miniconda3
conda activate RNA

cd /home/$USER/m5C-UBSseq/data-processing-1

start_time=$(date +%s)

# Function to run a command and check its exit status
run_command() {
    local command=$1
    local description=$2
    echo "Starting $description..."
    if ! $command; then
        echo "Error: $description failed"
        exit 1
    fi
}

echo "Processing directory: $1"

# Sequential execution
run_command "./cutseq.sh $1" "cutseq"
run_command "./hisat-3n-1.sh $1 $3" "hisat-3n-1"
run_command "./samtools-1.sh $1" "samtools-1"
run_command "./hisat-3n-2.sh $1 $2" "hisat-3n-2"
run_command "./samtools-2.sh $1" "samtools-2"

# Parallel execution of samtools-3 and java
echo "Starting samtools-3 and java jobs..."
./samtools-3.sh "$1" &
samtools_3_pid=$!
./java.sh "$1" &
java_pid=$!

# Wait for both jobs to complete
# wait $samtools_3_pid $java_pid
wait $java_pid

# Check exit status
if [ $? -ne 0 ]; then
    echo "Error: java job failed"
    exit 1
fi

# Parallel execution of samtools-4,5,6,7
echo "Starting samtools-4,5,6,7 jobs..."
./samtools-4.sh "$1" &
pid4=$!
./samtools-5.sh "$1" "$2" &
pid5=$!
./samtools-6.sh "$1" "$2" &
pid6=$!
./samtools-7.sh "$1" &
pid7=$!

wait $pid7

if [ $? -ne 0 ]; then
    echo "Error: samtools-7 failed"
    exit 1
fi

# Parallel execution of samtools-8,9
echo "Starting samtools-8,9 jobs..."
./samtools-8.sh "$1" "$2" &
pid8=$!
./samtools-9.sh "$1" "$2" &
pid9=$!

# Wait for both jobs to complete
wait $pid5 $pid6 $pid8 $pid9

if [ $? -ne 0 ]; then
    echo "Error: One of the samtools-5,6,8,9 jobs failed"
    exit 1
fi

# Final join
run_command "./join.sh $1" "join"

end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

echo "Directory: $1"
echo "All jobs completed successfully!"
echo "Total duration: ${hours}h ${minutes}m ${seconds}s"
