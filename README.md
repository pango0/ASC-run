
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
- Reference data 
    ```bash
    mkdir -p /work/$USER/RNA/reference/

    # Download Genome Data

    cd /work/$USER/RNA/reference
    wget https://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    mv Homo_sapiens.GRCh38.dna.primary_assembly.fa Homo_sapiens.GRCh38.genome.fa

    # Download ncRNA Data

    cd /work/$USER/RNA/reference
    wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/gencode.v47.lncRNA_transcripts.fa.gz
    gunzip gencode.v47.lncRNA_transcripts.fa.gz
    mv gencode.v47.lncRNA_transcripts.fa Homo_sapiens.GRCh38.sncRNA.fa

    ```

- Raw data 
    ```bash
    mkdir -p /work/$USER/RNA/test-data/
    cd /work/$USER/RNA/test-data/
    prefetch GSM7051146
    prefetch GSM7051147
    prefetch GSM7051148

    fastq-dump --split-files SRR23538292 # GSM7051146
    fastq-dump --split-files SRR23538291 # GSM7051147
    fastq-dump --split-files SRR23538290 # GSM7051148

    mkdir SRR23538292
    mkdir SRR23538291
    mkdir SRR23538290

    mv SRR23538292_1.fastq SRR23538292/SRR23538292.fq
    mv SRR23538291_1.fastq SRR23538291/SRR23538291.fq
    mv SRR23538290_1.fastq SRR23538290/SRR23538290.fq
    ```

## Expected Directory Structure
```
data
└── RNA
    ├── reference
    │   ├── Homo_sapiens.GRCh38.genome.fa
    │   └── Homo_sapiens.GRCh38.sncRNA.fa
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
Put absolute path of required testing data and reference data into `config.yaml`



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
