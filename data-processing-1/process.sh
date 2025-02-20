echo "Start processing datasets stage 1"

# Record start time
start_time=$(date +%s)


# Array to store job IDs
declare -a job_ids

# # Launch jobs and store their IDs
# job_ids[0]=$(sbatch --parsable process-dataset.sh $1 $4 $5)
# job_ids[1]=$(sbatch --parsable process-dataset.sh $2 $4 $5)
# job_ids[2]=$(sbatch --parsable process-dataset.sh $3 $4 $5)

# First two job: 6 GPUs
job_ids[0]=$(sbatch --parsable --gpus-per-node=6 process-dataset.sh $1 $4 $5 48)
job_ids[1]=$(sbatch --parsable --gpus-per-node=6 process-dataset.sh $2 $4 $5 48)

# third job:  8 GPUs
job_ids[2]=$(sbatch --parsable --gpus-per-node=6 process-dataset.sh $3 $4 $5 48)

echo "Launched jobs with IDs: ${job_ids[@]}"
launch_time=$(date +%s)
echo "Time taken to launch jobs: $(($launch_time - $start_time)) seconds"

# Function to check if a job is still running
job_running() {
    local job_id=$1
    if squeue -j "$job_id" --noheader &> /dev/null; then
        return 0  # Job is still running
    else
        return 1  # Job has completed
    fi
}

# Wait for all jobs to complete
echo "Waiting for all jobs to complete..."
while true; do
    all_complete=true
    for job_id in "${job_ids[@]}"; do
        if job_running "$job_id"; then
            all_complete=false
            break
        fi
    done
    
    if [ "$all_complete" = true ]; then
        break
    fi
    
    sleep 10  # Check every minute
done

# Calculate execution time
end_time=$(date +%s)
total_runtime=$((end_time - start_time))
hours=$((total_runtime / 3600))
minutes=$(((total_runtime % 3600) / 60))
seconds=$((total_runtime % 60))

echo "All jobs have completed"
echo "Stage 1 total execution time: ${hours}h ${minutes}m ${seconds}s"
echo "Time breakdown:"
echo "- Job launch time: $(($launch_time - $start_time)) seconds"
echo "- Job execution time: $(($end_time - $launch_time)) seconds"
# echo "Start processing datasets stage 1"

# # Record the start time
# start_time=$(date +%s)

# # Launch subprocesses and run them in the background
# ./process-dataset.sh "$1" "$4" "$5" &
# pid1=$!
# ./process-dataset.sh "$2" "$4" "$5" &
# pid2=$!
# ./process-dataset.sh "$3" "$4" "$5" &
# pid3=$!

# # Display launched job PIDs
# echo "Launched jobs with PIDs: $pid1 $pid2 $pid3"
# launch_time=$(date +%s)
# echo "Time taken to launch jobs: $(($launch_time - $start_time)) seconds"

# # Wait for all background jobs to complete
# echo "Waiting for all jobs to complete..."
# wait $pid1
# wait $pid2
# wait $pid3

# # Calculate execution time
# end_time=$(date +%s)
# total_runtime=$((end_time - start_time))
# hours=$((total_runtime / 3600))
# minutes=$(((total_runtime % 3600) / 60))
# seconds=$((total_runtime % 60))

# echo "All jobs have completed"
# echo "Stage 1 total execution time: ${hours}h ${minutes}m ${seconds}s"
# echo "Time breakdown:"
# echo "- Job launch time: $(($launch_time - $start_time)) seconds"
# echo "- Job execution time: $(($end_time - $launch_time)) seconds"
