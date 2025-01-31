#!/usr/bin/env bash

# ----------------------------------------
# Script Configuration
# ----------------------------------------

# User-defined input file
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

INPUT_FILE="$1"
TRUE_SITES="HeLa-WT_sites.tsv"
# OUTPUT_FILE="output_filtered.tsv"

# Validate input files
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file '$INPUT_FILE' does not exist."
  exit 1
fi

if [[ ! -f "$TRUE_SITES" ]]; then
  echo "Error: True sites file '$TRUE_SITES' does not exist."
  exit 1
fi

# Temporary files
TRUE_UR="true_ur.txt"
DETECTED_UR="detected_ur.txt"
OVERLAP_UR="overlap_ur.txt"

# Cleanup function to remove intermediate files
cleanup() {
#   echo "Cleaning up intermediate files..."
  rm -f "$TRUE_UR" "$DETECTED_UR" "$OVERLAP_UR"
}
trap cleanup EXIT

# ----------------------------------------
# Step 1: Preprocessing
# ----------------------------------------

# echo "[Step 1] Filtering Input File..."
# awk -F '\t' 'NR==1 || $7 < 1e-6' "$INPUT_FILE" > "$OUTPUT_FILE"

# if [[ -f "$OUTPUT_FILE" ]]; then
#   echo "Filtered rows saved to '$OUTPUT_FILE'."
# else
#   echo "Error: Failed to create filtered output file."
#   exit 1
# fi

# ----------------------------------------
# Step 2: Preprocess True Sites
# ----------------------------------------

# echo "[Step 2] Preprocessing True Sites..."
awk 'BEGIN{FS=OFS="\t"} NR>1 && NF>=9 {print $1, $2, $3, $9}' "$TRUE_SITES" > "$TRUE_UR"

if [[ ! -s "$TRUE_UR" ]]; then
  echo "Error: Processed true sites file is empty."
  exit 1
fi

# ----------------------------------------
# Step 3: Preprocess Detected Sites
# ----------------------------------------

# echo "[Step 3] Preprocessing Detected Sites..."
awk 'BEGIN{FS=OFS="\t"} $8=="true" {print $1, $2, $3, $6}' "$1" > "$DETECTED_UR"

if [[ ! -s "$DETECTED_UR" ]]; then
  echo "Error: Processed detected sites file is empty."
  exit 1
fi

# ----------------------------------------
# Step 4: Precision Calculation
# ----------------------------------------

# echo "[Step 4] Calculating Precision..."
TP=$(awk 'NR==FNR {a[$1,$2,$3]=1; next} ($1,$2,$3) in a' "$TRUE_UR" "$DETECTED_UR" | wc -l)
TOTAL_DETECTED=$(wc -l < "$DETECTED_UR")

PRECISION=$(awk -v tp="$TP" -v total="$TOTAL_DETECTED" \
  'BEGIN {if (total==0) {print 0} else {printf "%.2f", (tp/total)*100}}')

echo "Precision = ${PRECISION}%"

# ----------------------------------------
# Step 5: Correlation Calculation
# ----------------------------------------

# echo "[Step 5] Calculating Correlation..."
awk 'NR==FNR {a[$1,$2,$3]=$4; next} ($1,$2,$3) in a {print a[$1,$2,$3], $4}' "$TRUE_UR" "$DETECTED_UR" > "$OVERLAP_UR"

if [[ ! -s "$OVERLAP_UR" ]]; then
  echo "Correlation = NaN"
  echo "[FAIL] Precision or Correlation did not meet the standard"
  exit 1
fi

CORRELATION=$(awk '{
  x = $1; y = $2
  sumXY += x * y
  sumX  += x
  sumY  += y
  sumX2 += x * x
  sumY2 += y * y
  n++
} END {
  numerator   = n * sumXY - sumX * sumY
  denominator = sqrt((n * sumX2 - sumX^2) * (n * sumY2 - sumY^2))
  if (n == 0 || denominator == 0) {
    print "NaN"
  } else {
    printf "%.3f", numerator / denominator
  }
}' "$OVERLAP_UR")

echo "Correlation = ${CORRELATION}"

# ----------------------------------------
# Step 6: Result Validation
# ----------------------------------------

# echo "[Step 6] Validating Results..."

if (( $(awk -v p="$PRECISION" 'BEGIN{print (p>=95.0)?1:0}') )) && \
   (( $(awk -v c="$CORRELATION" 'BEGIN{print (c>=0.90)?1:0}') ))
then
  echo "[PASS] Precision >= 95% and Correlation >= 0.90"
else
  echo "[FAIL] Precision or Correlation did not meet the standard"
fi

# Cleanup intermediate files
cleanup

# echo "Script completed successfully."
