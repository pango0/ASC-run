#!/bin/bash
#SBATCH --job-name=run
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

# Function to handle errors
handle_error() {
    local stage=$1
    local exit_code=$2
    echo "ERROR: ${stage} failed with exit code ${exit_code}" >&2
    exit ${exit_code}
}

# Function to display usage
usage() {
    echo "Usage: $0 <genome_path> <ncRNA_path> <test_dir1> <test_dir2> <test_dir3>"
    echo
    echo "Arguments:"
    echo "  genome_path   Path to genome file"
    echo "  ncRNA_path    Path to ncRNA file"
    echo "  test_dir1     First test directory"
    echo "  test_dir2     Second test directory"
    echo "  test_dir3     Third test directory"
    exit 1
}

echo "Start run"
start_time=$(date +%s)

# Check if required arguments are provided
if [ $# -ne 5 ]; then
    echo "Error: Five arguments required" >&2
    usage
fi

# Check if input files exist
if [ ! -f "$1" ]; then
    echo "ERROR: Genome file $1 does not exist" >&2
    exit 1
fi

if [ ! -f "$2" ]; then
    echo "ERROR: ncRNA file $2 does not exist" >&2
    exit 1
fi

# Load modules and activate conda environment
module load miniconda3
conda activate rna_env

# Run indexing stage
echo "Running indexing stage..."
cd "/home/$USER/m5C-UBSseq/build-index" || handle_error "Changing to build-index directory" $?
if ! ./build-index.sh "${1}" "${2}"; then
    handle_error "Indexing stage" $?
fi

# Run stage 1
echo "Running stage 1 processing..."
cd "/home/$USER/m5C-UBSseq/data-processing-1" || handle_error "Changing to data-processing-1 directory" $?
if ! ./process.sh "${3}" "${4}" "${5}" "${1}" "${2}"; then
    handle_error "Stage 1 processing" $?
fi

# Run stage 2
echo "Running stage 2 processing..."
cd "/home/$USER/m5C-UBSseq/data-processing-2" || handle_error "Changing to data-processing-2 directory" $?
if ! ./process.sh "${3}" "${4}" "${5}"; then
    handle_error "Stage 2 processing" $?
fi

end_time=$(date +%s)
total_runtime=$((end_time - start_time))
hours=$((total_runtime / 3600))
minutes=$(((total_runtime % 3600) / 60))
seconds=$((total_runtime % 60))
echo "Run total execution time: ${hours}h ${minutes}m ${seconds}s"
