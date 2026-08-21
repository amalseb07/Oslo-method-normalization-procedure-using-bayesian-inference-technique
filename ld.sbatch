#!/bin/bash

#SBATCH --job-name=ld
#SBATCH --mail-type=END
#SBATCH --mail-user=sebast64@msu.edu
#SBATCH --cpus-per-task=4
#SBATCH --mem=30G
#SBATCH --time=30:00:00
#SBATCH --output=%x-%j.SLURMout

# -----------------------------
# Initialize micromamba
# -----------------------------
# This line is usually required so that "micromamba activate" works in batch jobs
eval "$(micromamba shell hook --shell=bash)"

# Activate micromamba environment
micromamba activate ising_project

# Change to your script directory
cd /mnt/research/snlgroup/sebastian/100Zr-Bayes-analysis/100Y-toy-problem/all_together/all_together_divided/with_wide_prior/

# Run your script
python -u leveldensity.py
