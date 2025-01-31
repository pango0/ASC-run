
# ASC-run: RNA-seq Data Processing Pipeline

## Overview
This project is part of the 2025 ASC Student Supercomputer Challenge Preliminary Round for parallel processing to accelerate RNA-seq data processing pipeline for large-scale RNA-seq datasets.

## Environment Setup


### 1. Create conda environment
```bash
module load miniconda3
conda env create -f environment.yml
conda activate asc
```


### 2. Install required HISAT-3n
```bash
./installation.sh
```

## Data Preparation
```bash
prefetch GSM7051146
prefetch GSM7051147
prefetch GSM7051148

fastq-dump --split-files --gzip SRR23538292 # GSM7051146
fastq-dump --split-files --gzip SRR23538291 # GSM7051147
fastq-dump --split-files --gzip SRR23538290 # GSM7051148
```

## Expected Directory Structure
```
data
└── RNA
    ├── reference
    │   └── genome
    │       ├── Homo_sapiens.GRCh38.genome
    │       │   └── Homo_sapiens.GRCh38.genome.fa
    │       └── Homo_sapiens.GRCh38.sncRNA
    │           └── Homo_sapiens.GRCh38.sncRNA.fa
    └── test-data
        ├── SRR23538290
        │   ├── SRR23538290.fq
        │   ├── SRR23538290.gz
        │   └── SRR23538290.sra
        ├── SRR23538291
        │   ├── SRR23538291.fq
        │   ├── SRR23538291.gz
        │   └── SRR23538291.sra
        └── SRR23538292
            ├── SRR23538292.fq
            ├── SRR23538292.gz
            └── SRR23538292.sra
```

## Running the Pipeline
### 1. Edit `config.yaml`
Put obsolute path of required testing data and reference data into `config.yaml`



### 2. Submit a Slurm Job
To process RNA-seq data, use `sbatch` to submit the `run.sh` script:
```bash
sbatch run.sh
```

## Testing Accuracy
```bash
./test.sh <filtered.tsv>
```



## Debugging

To add packages to conda environment, run:

```bash
conda env update -n asc --file environment.yml --prune   
```
