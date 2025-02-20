#!/bin/bash

#SBATCH --job-name=run
#SBATCH --partition=gp4d
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=180G
#SBATCH --time=96:00:00
#SBATCH --gpus-per-node=1
#SBATCH --account=ACD114010
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.err

export CUDA_VISIBLE_DEVICES=0,1

# store initial cwd
INITIAL_DIR=$(pwd)

# Function to handle errors
handle_error() {
    local stage=$1
    local exit_code=$2
    echo "ERROR: ${stage} failed with exit code ${exit_code}" >&2
    exit ${exit_code}
}

# Parse config.yaml
CONFIG_FILE="config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Extract parameters using Python
eval $(python3 - <<EOF
import yaml
with open("$CONFIG_FILE", "r") as f:
    config = yaml.safe_load(f)
print(f'GENOME_PATH="{config["genome_path"]}"')
print(f'NCRNA_PATH="{config["ncRNA_path"]}"')
print(f'TEST_DIRS=({" ".join(config["test_dirs"])})')
EOF
)

# Check extracted values
echo "Genome Path: $GENOME_PATH"
echo "ncRNA Path: $NCRNA_PATH"
echo "Test Directories: ${TEST_DIRS[@]}"

echo "-"

# Process each test directory
for INPUT_DIR in "${TEST_DIRS[@]}"; do
    # Ensure the directory exists
    if [ ! -d "$INPUT_DIR" ]; then
        echo "Error: Directory $INPUT_DIR does not exist. Skipping..."
        continue
    fi

    # Extract directory name (e.g., "SRR23538290")
    DIR_NAME=$(basename "$INPUT_DIR")

    FQ_FILE="$INPUT_DIR/$DIR_NAME.fq"

    # If .fq file already exists, skip decompression
    if [ -f "$FQ_FILE" ]; then
        echo "Skipping decompression: $FQ_FILE already exists."
        continue
    fi

    # Locate the expected .gz file
    GZ_FILE="$INPUT_DIR/$DIR_NAME.gz"

    # Ensure the .gz file exists
    if [ ! -f "$GZ_FILE" ]; then
        echo "Error: Expected .gz file $GZ_FILE not found. Skipping..."
        continue
    fi

    # Decompress .gz to .fq
    echo "Decompressing $GZ_FILE -> $FQ_FILE"
    gunzip -c "$GZ_FILE" > "$FQ_FILE"

    # Verify decompression was successful
    if [[ -f "$FQ_FILE" ]]; then
        echo "Successfully decompressed: $FQ_FILE"
    else
        echo "Error: Decompression failed for $GZ_FILE."
    fi
done


echo "Start run"
start_time=$(date +%s)

# Load modules and activate conda environment
module load miniconda3
conda activate asc

# Run indexing stage
# echo "Running indexing stage..."
cd "./build-index" || handle_error "Changing to build-index directory" $?
if ! ./build-index.sh "$GENOME_PATH" "$NCRNA_PATH"; then
    handle_error "Indexing stage" $?
fi

stage1_start_time=$(date +%s)

# Run stage 1
echo "Running stage 1 processing..."
cd "../data-processing-1" || handle_error "Changing to data-processing-1 directory" $?
if ! ./process.sh "${TEST_DIRS[@]}" "$GENOME_PATH" "$NCRNA_PATH"; then
    handle_error "Stage 1 processing" $?
fi

# Run stage 2
echo "Running stage 2 processing..."
cd "../data-processing-2" || handle_error "Changing to data-processing-2 directory" $?
if ! ./process.sh "${TEST_DIRS[@]}"; then
    handle_error "Stage 2 processing" $?
fi

# return to init dir
cd "$INITIAL_DIR" || handle_error "Returning to initial directory" $?
FINAL_DIR="$INITIAL_DIR/final_result"
mkdir -p "$FINAL_DIR"

for INPUT_DIR in "${TEST_DIRS[@]}"; do
    INPUT_FILE="$INPUT_DIR/gene.filtered.tsv"
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Skipping $INPUT_DIR: gene.tsv not found."
        continue
    fi

    DIR_NAME=$(basename "$INPUT_DIR")
    OUTPUT_FILE="$FINAL_DIR/${DIR_NAME}_filtered.tsv"

    echo "Processing $INPUT_FILE -> $OUTPUT_FILE"
    awk -F '\t' 'NR==1 || $7 < 1e-6' "$INPUT_FILE" > "$OUTPUT_FILE"

    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "Successfully created: $OUTPUT_FILE"
    else
        echo "Error: Failed to create $OUTPUT_FILE."
    fi
done


end_time=$(date +%s)
total_runtime=$((end_time - start_time))
hours=$((total_runtime / 3600))
minutes=$(((total_runtime % 3600) / 60))
seconds=$((total_runtime % 60))
echo "Run total execution time: ${hours}h ${minutes}m ${seconds}s"

stage1_to_end_runtime=$((end_time - stage1_start_time))
s1_hours=$((stage1_to_end_runtime / 3600))
s1_minutes=$(((stage1_to_end_runtime % 3600) / 60))
s1_seconds=$((stage1_to_end_runtime % 60))

echo "Execution time (cutseq -> End execution time): ${s1_hours}h ${s1_minutes}m ${s1_seconds}s"
